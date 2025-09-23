Tool – Automatic Test Class Generator for InterSystems IRIS

This project provides a Python utility to automatically generate and execute unit tests for classes in InterSystems IRIS.
It dynamically inspects a given IRIS class, extracts its public class methods, and generates a Python-based test class that validates their execution with sample input values.

🚀 Features

🔍 Class Introspection
Uses %Dictionary.ClassDefinition to explore class metadata and methods.

⚙️ Automatic Test Class Generation
Creates a new Python test class for each IRIS class inspected, stored in /tmp.

🧪 Method Invocation with Fake Data
Supports generating fake values for method parameters based on IRIS data types (%String, %Integer, %Float, %Date, etc.).

✅ Field Validation
Validates parameters against schema constraints using %Dictionary.CompiledPropertyDefinition.

📊 Execution Report
Each test run shows:

Total tests executed

Number of successes

Number of failures

Success rate percentage

🔄 Reusable Test Runner
Generated test classes can be executed later with the built-in runner.

📦 Installation

Ensure you have InterSystems IRIS installed and accessible.

Install the Python iris library (usually provided with IRIS Python client):

pip install intersystems-iris


Clone or copy this repository into your project.

🛠 Usage
1. Generate a Test Class
from tool import Tool

Tool.generate_test_for_class("Demo.App.Customer")


➡️ This will:

Inspect the class Demo.App.Customer.

Create a new Python file under /tmp/Demo_App_CustomerTest.py.

Include automatically generated test methods.

2. Run the Generated Test
Tool.run_test("ToolQA.tool.QA.CustomerTest")


➡️ This will:

Import the generated test module.

Run all tests inside it.

Print a summary report.

📂 Example – End-to-End
Step 1: Example IRIS Class (Demo.App.Customer.cls)
Class Demo.App.Customer Extends (%RegisteredObject, %Library.ClassDefinition) {

ClassMethod GetCustomerName(ByVal ID As %Integer) As %String
{
    Quit "Customer #" _ ID
}

ClassMethod CalculateDiscount(ByVal Amount As %Double) As %Double
{
    Quit Amount * 0.1
}

}

Step 2: Generate Test Class in Python
from tool import Tool

Tool.generate_test_for_class("Demo.App.Customer")


This creates /tmp/Demo_App_CustomerTest.py with code like:

import iris
import traceback

class ToolQA_tool_QA_CustomerTest:
    '''
    Class test automatizeded to Demo.App.Customer
    Create on: 2025-09-23 13:00:00
    '''

    @classmethod
    def run(cls):
        print('Starting tests for: Demo.App.Customer')
        print('-' * 50)
        errors = 0
        tests = 0

        # Testing method: GetCustomerName
        tests += 1
        try:
            print(f'\nTesting method: GetCustomerName')
            ID = 123
            api_class = iris.cls('Demo.App.Customer')
            result = api_class.GetCustomerName(ID)
            print(f'  ✓ Method GetCustomerName executed with sucess')
            if result:
                print(f'    Result: {result}')
        except Exception as ex:
            errors += 1
            print(f'  ✗ Error in test GetCustomerName: {str(ex)}')
            print(f'    Traceback: {traceback.format_exc()}')

        # Testing method: CalculateDiscount
        tests += 1
        try:
            print(f'\nTesting method: CalculateDiscount')
            Amount = 123.45
            api_class = iris.cls('Demo.App.Customer')
            result = api_class.CalculateDiscount(Amount)
            print(f'  ✓ Method CalculateDiscount executed with sucess')
            if result:
                print(f'    Result: {result}')
        except Exception as ex:
            errors += 1
            print(f'  ✗ Error in test CalculateDiscount: {str(ex)}')
            print(f'    Traceback: {traceback.format_exc()}')

        # Resume tests
        print('-' * 50)
        print(f'\nResume Tests:')
        print(f'  Total tests: {tests}')
        print(f'  Sucess: {tests - errors}')
        print(f'  Fails: {errors}')
        success_rate = ((tests - errors) / tests * 100) if tests > 0 else 0
        print(f'  Tax of sucess: {success_rate:.2f}%')
        return errors == 0

Step 3: Run Tests
Tool.run_test("ToolQA.tool.QA.CustomerTest")


Console Output:

Starting tests for: Demo.App.Customer
--------------------------------------------------

Testing method: GetCustomerName
  ✓ Method GetCustomerName executed with sucess
    Result: Customer #123

Testing method: CalculateDiscount
  ✓ Method CalculateDiscount executed with sucess
    Result: 12.345

--------------------------------------------------
Resume Tests:
  Total tests: 2
  Sucess: 2
  Fails: 0
  Tax of sucess: 100.00%

🔮 Roadmap

 Add support for instance methods (not only class methods).

 Improve fake data generator with more realistic values.

 Add integration with pytest for better automation.

 Extend validation to foreign keys and enumerations.

📜 License

This project is released under the MIT License.
Feel free to use, modify, and distribute.