📘 Description of ToolQA.tool.BP.Tool Test Generation Class
Overview
The class ToolQA.tool.BP.Tool is designed as an automated intelligent test agent for API classes in InterSystems IRIS. Its main responsibility is to:

Automatically generate test classes for any provided API class;

Introspect the API class methods and parameters using IRIS class metadata;

Generate synthetic test values for each method parameter based on its type;

Validate those test values against your database schema before invoking the API method, ensuring type and boundary compliance;

Compile and save the generated test class in the IRIS environment;

Provide an executable Run() method within the generated test class to perform the tests and report results.

**How It Works**
1. Input
You call the method:

DO ##class(ToolQA.tool.BP.Tool).GenerateTestForClass("Your.API.ClassName")
with the fully qualified name of the API class you want to test.

2. Introspection and Metadata Analysis
The tool uses IRIS’ %Dictionary.ClassDefinition to:

Open the API class definition;

Enumerate all public class methods;

Extract each method’s parameter names and types.

3. Synthetic Test Data Generation
For each method parameter:

The method CreateFakeValue generates a dummy value compatible with the parameter’s type (e.g., string, integer, double);

The tool attempts to find a mapping between parameters and persistent database classes/fields through the ClassBank method, scanning known persistent classes for matching fields;

If a mapping exists, the generated dummy value is validated against the database field’s type and constraints (ValidateValueField), checking type correctness, length limits, and numeric bounds.

4. Test Class Generation
The agent dynamically creates a new test class with the naming convention:


AXS.QA.Tests.<APIClassName>Test
The class contains a Run() class method that:

Prints the test start message;

Executes each API method with generated parameters, after validation;

Catches and logs errors or exceptions during method calls;

Reports test success or failure.

5. Compilation and Execution
The generated test class is saved as a .cls file and compiled automatically within IRIS. You then execute tests by running:

DO ##class(AXS.QA.Tests.<APIClassName>Test).Run()
How Responses and Results Are Handled
The test class captures the return status (%Status) of each API method call;

Errors (non-success status codes) are printed to the console with details;

Exceptions thrown by API methods are caught and logged with their stack trace;

Since the agent generates synthetic inputs, it does not currently validate response content beyond execution success — but you can extend the test class to add assertions on output objects or returned data structures as needed.

🐳 Step-by-Step Guide: Docker Installation and Running Tests
This section assumes you want to run your InterSystems IRIS instance with Docker and deploy/test your classes in this environment.

Step 1: Install Docker
For Windows or macOS
Download Docker Desktop:
https://www.docker.com/products/docker-desktop

Run the installer and follow the setup instructions.

After installation, launch Docker Desktop and verify it's running by opening a terminal/PowerShell and running:

docker --version
You should see the Docker version printed.

For Linux (Ubuntu example)

sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version
Step 2: Pull InterSystems IRIS Community Edition Docker Image

docker pull intersystems/iris-community
Step 3: Run IRIS Container
Run the container with ports exposed (you can customize the ports):

docker run --name my-iris -d \
  -p 52773:52773 \
  -p 52774:52774 \
  -e ISC_PASSWORD=YourPasswordHere \
  intersystems/iris-community
Replace YourPasswordHere with a secure password.

Step 4: Access IRIS Management Portal
Open a browser and navigate to:

http://localhost:52773/csp/sys/UtilHome.csp
Login with:

Username: _SYSTEM

Password: the one you set for ISC_PASSWORD

Step 5: Import Your Classes
You can either:

Use the Management Portal’s Code Editor to paste your .cls code (including ToolQA.tool.BP.Tool and your API classes), then compile;
OR

Use Docker volumes or IRIS Terminal to load .cls files.

Step 6: Run the Test Generation
In IRIS Terminal or Studio:

DO ##class(ToolQA.tool.BP.Tool).GenerateTestForClass("ToolQA.tool.BP.forecast")
This creates the test class:

AXS.QA.Tests.forecastTest
Step 7: Execute the Generated Tests
In Terminal or Studio:

DO ##class(AXS.QA.Tests.forecastTest).Run()
Watch the output for:

Test start message;

Each method tested with success or failure output;

Any errors or exceptions printed.

🔧 Extending and Customizing
Add more precise mapping logic inside ClassBank() to fit your domain classes;

Extend CreateFakeValue() to produce more realistic test data;

Add assertions to test response content or database side effects after method calls;

Integrate with CI/CD pipelines for automated regression testing.
