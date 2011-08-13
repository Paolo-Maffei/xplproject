Imports Microsoft.VisualStudio.TestTools.UnitTesting

Imports xPL



'''<summary>
'''This is a test class for xPLFragmentedMsgTest and is intended
'''to contain all xPLFragmentedMsgTest Unit Tests
'''</summary>
<TestClass()> _
Public Class xPLFragmentedMsgTest


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


    '''<summary>
    '''A test for Source
    '''</summary>
    <TestMethod()> _
    Public Sub SourceTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As String
        actual = target.Source
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for Received
    '''</summary>
    <TestMethod()> _
    Public Sub ReceivedTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As Boolean
        actual = target.Received
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for Parent
    '''</summary>
    <TestMethod()> _
    Public Sub ParentTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As xPLDevice
        actual = target.Parent
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for NoOfFragments
    '''</summary>
    <TestMethod()> _
    Public Sub NoOfFragmentsTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As Integer
        actual = target.NoOfFragments
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for MessageID
    '''</summary>
    <TestMethod()> _
    Public Sub MessageIDTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As String
        actual = target.MessageID
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for IsComplete
    '''</summary>
    <TestMethod()> _
    Public Sub IsCompleteTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As Boolean
        actual = target.IsComplete
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for Created
    '''</summary>
    <TestMethod()> _
    Public Sub CreatedTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim actual As Boolean
        actual = target.Created
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for Send
    '''</summary>
    <TestMethod()> _
    Public Sub SendTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        target.Send()
        Assert.Inconclusive("A method that does not return a value cannot be verified.")
    End Sub

    '''<summary>
    '''A test for ResendFailedParts
    '''</summary>
    <TestMethod()> _
    Public Sub ResendFailedPartsTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim msg1 As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim expected As Boolean = False ' TODO: Initialize to an appropriate value
        Dim actual As Boolean
        actual = target.ResendFailedParts(msg1)
        Assert.AreEqual(expected, actual)
        Assert.Inconclusive("Verify the correctness of this test method.")
    End Sub

    '''<summary>
    '''A test for AddFragment
    '''</summary>
    <TestMethod()> _
    Public Sub AddFragmentTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent) ' TODO: Initialize to an appropriate value
        Dim msg1 As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        target.AddFragment(msg1)
        Assert.Inconclusive("A method that does not return a value cannot be verified.")
    End Sub

    '''<summary>
    '''A test for xPLFragmentedMsg Constructor
    '''</summary>
    <TestMethod()> _
    Public Sub xPLFragmentedMsgConstructorTest()
        Dim msg As xPLMessage = Nothing ' TODO: Initialize to an appropriate value
        Dim Parent As xPLDevice = Nothing ' TODO: Initialize to an appropriate value
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, Parent)
        Assert.Inconclusive("TODO: Implement code to verify target")
    End Sub
End Class
