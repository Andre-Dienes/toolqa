Class ToolQA.tool.BP.Tool Extends Ens.BusinessProcess
{
ClassMethod GenerateTestForClass(apiClassName As %String) As %Status [ Language = python ]
{
    import iris, os, sys, re, traceback
    from datetime import datetime

    # Ensure tmp dir is portable
    try:
        tmpdir = iris.system.Util.GetEnviron("ISC_TMPDIR")
        if not tmpdir:
            tmpdir = "/tmp"
    except Exception:
        tmpdir = "/tmp"

    if tmpdir not in sys.path:
        sys.path.append(tmpdir)

    class Tool:
        @classmethod
        def _parse_formal_spec(cls, formal_spec):
            params = []
            if not formal_spec:
                return params

            spec = formal_spec.strip()
            if not spec:
                return params

            # Split top-level commas (basic split; IRIS formal specs are usually simple)
            param_list = spec.split(',')

            for param in param_list:
                param = param.strip()
                if not param:
                    continue

                parts = param.split(':')
                param_name = parts[0].strip()

                # Remove ByRef/Output/& tokens
                param_name = re.sub(r'^(ByRef\s+|Output\s+|&)', '', param_name, flags=re.IGNORECASE)
                # Remove default assignment if present in the name part (rare)
                param_name = param_name.split('=')[0].strip()

                param_type = '%String'
                if len(parts) > 1:
                    type_part = parts[1].strip()
                    # Remove default values in type part
                    type_part = type_part.split('=')[0].strip()
                    if type_part:
                        param_type = type_part

                params.append({
                    'name': param_name,
                    'type': param_type
                })

            return params

        @classmethod
        def _create_fake_value(cls, data_type):
            if not data_type:
                return "'default_value'"

            type_lower = data_type.lower().strip()
            type_lower = type_lower.replace('%', '')

            if 'string' in type_lower or 'varchar' in type_lower or 'text' in type_lower:
                return "'test_string'"
            elif 'integer' in type_lower or re.search(r'\bint\b', type_lower):
                return "123"
            elif 'double' in type_lower or 'float' in type_lower or 'decimal' in type_lower:
                return "123.45"
            elif 'boolean' in type_lower or 'bool' in type_lower:
                return "True"
            elif 'date' in type_lower and 'time' not in type_lower:
                return "'2024-01-01'"
            elif 'time' in type_lower and 'date' not in type_lower:
                return "'12:00:00'"
            elif 'timestamp' in type_lower or 'datetime' in type_lower:
                return "'2024-01-01 12:00:00'"
            elif 'list' in type_lower or 'array' in type_lower:
                return "['item1', 'item2']"
            elif 'object' in type_lower or 'map' in type_lower or 'dict' in type_lower:
                return "{'k1':'v1'}"
            else:
                return "'default_value'"

        @classmethod
        def _find_schema_class(cls, field_name):
            try:
                query = """
                SELECT parent FROM %Dictionary.CompiledProperty
                WHERE parent %STARTSWITH 'ToolQA.tool.'
                AND Name = ?
                """
                rs = iris.sql.exec(query, field_name)
                if rs.next():
                    return rs.get(0)
                return None
            except Exception:
                return None

        @classmethod
        def validate_field_value(cls, class_name, field_name, value):
            try:
                prop_id = f"{class_name}||{field_name}"
                prop = iris.cls('%Dictionary.CompiledPropertyDefinition')._OpenId(prop_id)
                if not prop:
                    # property not found on class
                    print(f"field {field_name} not found on class {class_name}")
                    return False

                prop_type = prop.Type if getattr(prop, 'Type', None) else '%String'
                max_len = getattr(prop, 'MaxLen', 0) or 0
                min_val = getattr(prop, 'MinVal', None)
                max_val = getattr(prop, 'MaxVal', None)

                # Normalize type
                pt = (prop_type or '%String').lower()

                if '%integer' in pt or 'int' in pt:
                    if not isinstance(value, int):
                        try:
                            value = int(value)
                        except:
                            print(f"{field_name}: Expected Integer, received '{value}'")
                            return False

                elif '%double' in pt or '%float' in pt or 'double' in pt or 'float' in pt or 'decimal' in pt:
                    if not isinstance(value, (int, float)):
                        try:
                            value = float(value)
                        except:
                            print(f"{field_name}: Expected Float, received '{value}'")
                            return False

                elif '%string' in pt or 'char' in pt or 'text' in pt:
                    if max_len and len(str(value)) > int(max_len):
                        print(f"{field_name}: String exceeds limit of {max_len} characters")
                        return False

                # Numeric bounds
                if ('%integer' in pt or '%double' in pt or '%float' in pt or
                        'int' in pt or 'double' in pt or 'float' in pt or 'decimal' in pt):
                    try:
                        # value may be string — cast to float for comparison
                        cmp_value = float(value)
                        if min_val is not None and cmp_value < float(min_val):
                            print(f"{field_name}: Value {value} lower than allowed {min_val}")
                            return False
                        if max_val is not None and cmp_value > float(max_val):
                            print(f"{field_name}: Value {value} greater than allowed {max_val}")
                            return False
                    except Exception:
                        # If casting fails, validation fails
                        print(f"{field_name}: Could not compare numeric bounds for value '{value}'")
                        return False

                return True
            except Exception as ex:
                print(f"Error to validate field: {str(ex)}")
                return False

        @classmethod
        def _save_python_class(cls, class_name, code):
            try:
                python_class_name = class_name.replace('.', '_')
                file_path = os.path.join(tmpdir, f"{python_class_name}.py")
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(code)
                print(f"Python file saved in: {file_path}")
                return True
            except Exception as ex:
                print(f"Error to save Python class: {str(ex)}")
                return False

        @classmethod
        def generate_test_for_class(cls, api_class_name):
            try:
                class_def = iris.cls('%Dictionary.ClassDefinition')._OpenId(api_class_name)
                if not class_def:
                    print(f"Error: Class {api_class_name} not found")
                    return 0

                last_piece = api_class_name.split('.')[-1]
                test_class_name = f"ToolQA.tool.QA.{last_piece}Test"

                # Begin building test file code
                code_lines = []
                code_lines.append("import iris")
                code_lines.append("import traceback")
                code_lines.append("from datetime import datetime")
                code_lines.append("")
                py_class_name = test_class_name.replace('.', '_')
                code_lines.append(f"class {py_class_name}:")
                code_lines.append("    '''")
                code_lines.append(f"    Class test automatized to {api_class_name}")
                code_lines.append(f"    Create on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                code_lines.append("    '''")
                code_lines.append("")
                code_lines.append("    @classmethod")
                code_lines.append("    def run(cls):")
                code_lines.append(f"        print('Starting tests for: {api_class_name}')")
                code_lines.append("        print('-' * 50)")
                code_lines.append("        errors = 0")
                code_lines.append("        tests = 0")
                code_lines.append("")

                methods = getattr(class_def, 'Methods', None)
                method_count = methods.Count() if methods else 0

                for i in range(1, method_count + 1):
                    method = methods.GetAt(i)
                    # Only public class methods (skip private and instance methods)
                    if getattr(method, 'ClassMethod', False) and not getattr(method, 'Private', False):
                        method_name = method.Name
                        if method_name.startswith('%'):
                            continue

                        code_lines.append(f"        # Testing method: {method_name}")
                        code_lines.append("        tests += 1")
                        code_lines.append("        try:")
                        code_lines.append(f"            print(f'\\nTesting method: {method_name}')")

                        formal_spec = getattr(method, 'FormalSpec', None)
                        args_code = []
                        arg_list = []

                        if formal_spec:
                            params = cls._parse_formal_spec(formal_spec)
                            for param in params:
                                param_name = param['name']
                                param_type = param['type']
                                test_value = cls._create_fake_value(param_type)

                                # declare variable
                                args_code.append(f"            {param_name} = {test_value}")

                                # check schema class for field validation
                                schema_class = cls._find_schema_class(param_name)
                                if schema_class:
                                    args_code.append(f"            # Validating field {param_name} with schema {schema_class}")
                                    # call validate routine packaged inside generated file (we'll include a local helper)
                                    args_code.append(f"            from iris import cls as _iris_cls")
                                    args_code.append(f"            # We will not call external validate function from here to keep generated test self-contained;")
                                    args_code.append(f"            # If you need pre-call validation, run Validate separately.")
                                    args_code.append(f"            # (Schema class detected: {schema_class})")

                                arg_list.append(param_name)

                        # append args declarations
                        if args_code:
                            for ln in args_code:
                                code_lines.append(ln)

                        args_str = ', '.join(arg_list) if arg_list else ''
                        code_lines.append("            # Calling the method")
                        code_lines.append(f"            api_class = iris.cls('{api_class_name}')")
                        if args_str:
                            code_lines.append(f"            result = api_class.{method_name}({args_str})")
                        else:
                            code_lines.append(f"            result = api_class.{method_name}()")
                        code_lines.append(f"            print(f'  ✓ Method {method_name} executed with success')")
                        code_lines.append("            if result is not None:")
                        code_lines.append("                print(f'    Result: {result}')")
                        code_lines.append("        except Exception as ex:")
                        code_lines.append("            errors += 1")
                        code_lines.append("            print(f'  ✗ Error in test {method_name}: {str(ex)}')")
                        code_lines.append("            print(f'    Traceback: {traceback.format_exc()}')")
                        code_lines.append("")

                # Resume summary
                code_lines.append("        # Resume tests")
                code_lines.append("        print('-' * 50)")
                code_lines.append("        print(f'\\nResume Tests:')")
                code_lines.append("        print(f'  Total tests: {tests}')")
                code_lines.append("        print(f'  Success: {tests - errors}')")
                code_lines.append("        print(f'  Fails: {errors}')")
                code_lines.append("        success_rate = ((tests - errors) / tests * 100) if tests > 0 else 0")
                code_lines.append("        print(f'  Success rate: {success_rate:.2f}%')")
                code_lines.append("        return errors == 0")
                code_lines.append("")

                code = '\n'.join(code_lines)

                success = cls._save_python_class(test_class_name, code)
                if success:
                    print(f"Class test created with success: {test_class_name}")
                    print(f"Python code saved in: {os.path.join(tmpdir, test_class_name.replace('.', '_') + '.py')}")
                    return 1
                else:
                    print("Error to save the class test")
                    return 0

            except Exception as ex:
                print(f"Error to create class test: {str(ex)}")
                traceback.print_exc()
                return 0

    # Execute generation
    try:
        res = Tool.generate_test_for_class(api_class_name)
        if res == 1:
            Quit 1
        else:
            Quit 0
    except Exception as ex:
        print(f"Unexpected error: {str(ex)}")
        traceback.print_exc()
        Quit 0
}

ClassMethod RunTest(testClassName As %String) As %Status [ Language = python ]
{
    import iris, sys, importlib, os, traceback

    try:
        # Ensure temp dir in path
        try:
            tmpdir = iris.system.Util.GetEnviron("ISC_TMPDIR")
            if not tmpdir:
                tmpdir = "/tmp"
        except Exception:
            tmpdir = "/tmp"

        if tmpdir not in sys.path:
            sys.path.append(tmpdir)

        module_name = testClassName.replace('.', '_')
        # importlib may cache modules: reload if already loaded to pick up changes
        if module_name in sys.modules:
            importlib.reload(sys.modules[module_name])
            module = sys.modules[module_name]
        else:
            module = importlib.import_module(module_name)

        test_class = getattr(module, module_name)
        print(f"Running tests from {testClassName} (module: {module_name})...")
        ok = test_class.run()

        if ok:
            print("All tests passed.")
            Quit 1
        else:
            print("Some tests failed.")
            Quit 0

    except Exception as ex:
        print(f"Error running test: {str(ex)}")
        traceback.print_exc()
        Quit 0
}
}
