Imports System
Imports System.Text
Imports System.Collections.Generic
Imports Microsoft.VisualStudio.TestTools.UnitTesting

<TestClass()> Public Class fragment

    Private testContextInstance As TestContext

    '''<summary>
    '''Gets or sets the test context which provides
    '''information about and functionality for the current test run.
    '''</summary>
    Public Property TestContext() As TestContext
        Get
            Return testContextInstance
        End Get
        Set(ByVal value As TestContext)
            testContextInstance = Value
        End Set
    End Property

#Region "Additional test attributes"
    '
    ' You can use the following additional attributes as you write your tests:
    '
    ' Use ClassInitialize to run code before running the first test in the class
    ' <ClassInitialize()> Public Shared Sub MyClassInitialize(ByVal testContext As TestContext)
    ' End Sub
    '
    ' Use ClassCleanup to run code after all tests in a class have run
    ' <ClassCleanup()> Public Shared Sub MyClassCleanup()
    ' End Sub
    '
    ' Use TestInitialize to run code before running each test
    <TestInitialize()> Public Sub MyTestInitialize()
        xPLTestInitialize()
    End Sub
    '
    ' Use TestCleanup to run code after each test has run
    <TestCleanup()> Public Sub MyTestCleanup()
        xPLTestCleanup()
    End Sub

#End Region

    ' when AutoFragment is set then
    '  - messages need to be automatically fragmented
    '  - exception if not possible due to a to large value
    '  - device should not receive fragments, only defragmented messages
    '  - timeouts for incomplete messages should work
    '  - requesting missing parts should work
    ' when not set then
    '  - to large messages will throw an exception, docs must be up-to-date!
    '  - fragments should be passed
    '  - defragmented messages should not be passed

    ' schema in message body is invalid or missing
    ' fragment key has incorrect format or missing

    <TestMethod()> Public Sub TestMethod1()
        ' TODO: Add test logic here
    End Sub

End Class
