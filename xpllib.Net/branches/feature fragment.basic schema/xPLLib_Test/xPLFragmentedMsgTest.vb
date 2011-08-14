Imports Microsoft.VisualStudio.TestTools.UnitTesting

Imports xPL
Imports xPL.xPL_Base
Imports System.Diagnostics


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
        Dim msg As New xPLMessage
        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = yDev.Address

        ' first test a message to be sent
        Debug.Print("1/2 Testing a message to be sent...")
        msg.KeyValueList.Add("somekey", "some value")
        For n = 0 To 9
            msg.KeyValueList.Add("testkey" & n.ToString, New String("A"c, 1000))
        Next
        msg.Source = xDev.Address
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, xDev) ' TODO: Initialize to an appropriate value
        Dim actual As String
        actual = target.Source
        Assert.IsTrue(xDev.Address = actual, "Fragmented source (" & actual & ") should have been equal to xdev.address (" & xDev.Address & ").")
        Debug.Print("Success: 'Source' property set as expected.")
        Assert.IsTrue(target.Created, "Fragmented message should have been created as a 'Created' message (to be sent).")
        Debug.Print("Success: 'Created' property set as expected.")
        Assert.IsTrue(target.Parent Is xDev, "Parent should have been the xDev instance, but isn't.")
        Debug.Print("Success: 'Parent' property set as expected.")
        Assert.IsTrue(target.MessageID = xDev.Address & ":1", "MessageID = '" & target.MessageID & "', while '" & xDev.Address & ":1" & "' was expected.")
        Debug.Print("Success: 'MessageID' property set as expected.")
        Assert.IsTrue(target.Count = 10, "Count = " & target.Count.ToString & ", while 10 was expected.")
        Debug.Print("Success: 'Count' property (# of fragments) set as expected.")
        Debug.Print("")

        ' second test a message received
        Debug.Print("2/2 Testing a message received...")
        msg.Source = yDev.Address
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("schema", msg.Schema)
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Add("partid", "1/7:34")
        msg.KeyValueList.Add("somekey", "some value")

        target = New xPLFragmentedMsg(msg, xDev) ' TODO: Initialize to an appropriate value
        actual = target.Source
        Assert.IsTrue(yDev.Address = actual, "Fragmented source (" & actual & ") should have been equal to ydev.address (" & yDev.Address & ").")
        Debug.Print("Success: 'Source' property set as expected.")
        Assert.IsTrue(target.Received, "Fragmented message should have been created as a 'Received' message.")
        Debug.Print("Success: 'Received' property set as expected.")
        Assert.IsTrue(target.Parent Is xDev, "Parent should have been the xDev instance, but isn't.")
        Debug.Print("Success: 'Parent' property set as expected.")
        Assert.IsTrue(target.MessageID = msg.Source & ":34", "MessageID = '" & target.MessageID & "', while '" & msg.Source & ":34" & "' was expected.")
        Debug.Print("Success: 'MessageID' property set as expected.")
        Assert.IsTrue(target.Count = 7, "Count = " & target.Count.ToString & ", while 7 was expected.")
        Debug.Print("Success: 'Count' property (# of fragments) set as expected.")

    End Sub

    'to be added;
    ' - no KV pairs in original message, both creating and receiving
    ' - bad structure; no schema, erroneous schema, no partid, or bad partid
End Class
