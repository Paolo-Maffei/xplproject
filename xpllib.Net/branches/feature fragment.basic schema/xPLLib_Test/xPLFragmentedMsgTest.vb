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
        For n As Integer = 1 To target.Count
            Assert.IsTrue(target.Fragment(n).KeyValueList.IndexOf("partid") = 0, "Expected the key 'partid' as the first key in fragment " & n.ToString & ".")
            Dim partid As String = target.Fragment(n).KeyValueList("partid")
            Assert.IsTrue(partid = n.ToString & "/" & target.Count & Mid(partid, partid.IndexOf(":") + 1), "Incorrect partid found in fragment " & n.ToString & ".")
            Debug.Print("Success: partid '" & partid & "' is the first key of fragment " & n.ToString & ", and seems ok.")
            If n = 1 Then
                Assert.IsTrue(target.Fragment(n).KeyValueList.IndexOf("schema") = 1, "Expected the key 'schema' as the second key in fragment " & n.ToString & ".")
                Assert.IsTrue(target.Fragment(n).KeyValueList("schema") = msg.Schema, "Schema in fragment 1, key 2, should have been '" & msg.Schema & "' instead of '" & target.Fragment(n).KeyValueList("schema") & "'.")
                Debug.Print("Success: fragment 1 contains the proper schema as key 2")
            End If
        Next
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

        ' test some error scenarios
        TestConstructorNoKVpairs()
    End Sub
    Private Sub TestConstructorNoKVpairs()
        ' - no KV pairs in original message, both creating and receiving

        Dim msg As New xPLMessage
        msg.Schema = "my.schema"
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = yDev.Address

        ' first test a message to be sent
        Debug.Print("")
        Debug.Print("TESTING CASE WITH NO KEY-VALUE PAIRS IN MESSAGE")
        Debug.Print("")
        Debug.Print("1/2 Testing a message to be sent...")
        'msg.KeyValueList.Add("somekey", "some value")
        'For n = 0 To 9
        '    msg.KeyValueList.Add("testkey" & n.ToString, New String("A"c, 1000))
        'Next
        msg.Source = xDev.Address
        Dim target As xPLFragmentedMsg = New xPLFragmentedMsg(msg, xDev) ' TODO: Initialize to an appropriate value
        Assert.IsTrue(xDev.Address = target.Source, "Fragmented source (" & target.Source & ") should have been equal to xdev.address (" & xDev.Address & ").")
        Debug.Print("Success: 'Source' property set as expected.")
        Assert.IsTrue(target.Created, "Fragmented message should have been created as a 'Created' message (to be sent).")
        Debug.Print("Success: 'Created' property set as expected.")
        Assert.IsTrue(target.Parent Is xDev, "Parent should have been the xDev instance, but isn't.")
        Debug.Print("Success: 'Parent' property set as expected.")
        Assert.IsTrue(target.MessageID = xDev.Address & ":2", "MessageID = '" & target.MessageID & "', while '" & xDev.Address & ":2" & "' was expected.")
        Debug.Print("Success: 'MessageID' property set as expected.")
        Assert.IsTrue(target.Count = 1, "Count = " & target.Count.ToString & ", while 1 was expected.")
        Debug.Print("Success: 'Count' property (# of fragments) set as expected.")
        Assert.IsTrue(target.Fragment(1).KeyValueList.IndexOf("partid") = 0, "Expected partid key as first key value pair")
        Assert.IsTrue(target.Fragment(1).KeyValueList.IndexOf("schema") = 1, "Expected schema key as second key value pair")
        Assert.IsTrue(target.Fragment(1).KeyValueList.Count = 2, "Expected only 2 keys in fragment 1")
        Debug.Print("Success: single fragment, with only the 2 fragment overhead keys in the correct order detected.")
        Debug.Print("")

        ' second test a message received
        Debug.Print("2/2 Testing a message received...")
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", msg.Schema) '"justsome.schema")

        Debug.Print("Created first fragment, now creating a new fragmented message...")
        target = New xPLFragmentedMsg(msg, xDev) ' create message from 1st fragment
        Debug.Print("Adding same fragment again to newly created fragmented message...")
        target.AddFragment(msg) ' Add same fragment again

        msg = New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "2/2:35")

        Dim msg2 As xPLMessage = target.AddFragment(msg)       ' add second fragment, now complete, so result should be returned

        Assert.IsTrue(msg.Source = msg2.Source, "Resulting source (" & msg2.Source & ") should have been equal to " & msg.Source & ".")
        Debug.Print("Success: 'Source' properties are equal.")
        Assert.IsTrue(msg.Target = msg2.Target, "Result target should have been " & msg.Target)
        Debug.Print("Success: 'Target' properties are equal")
        Assert.IsTrue(msg.Hop = msg2.Hop, "Result hop count should have been " & msg.Hop)
        Debug.Print("Success: 'Hop' properties are equal")
        Assert.IsTrue(msg2.KeyValueList.Count = 0, "Key-value pair count = " & msg.KeyValueList.Count.ToString & ", while 0 was expected.")
        Debug.Print("Success: no key-value pairs, as expected.")

    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErrorneousSchema1()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH NO SCHEMA IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... no schema")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")

        Dim target As xPLFragmentedMsg
        Dim ok As Boolean = False
        Try
            target = New xPLFragmentedMsg(msg, xDev)
        Catch ex As xPLFragmentedMsg.FragmentationException
            ok = True
        End Try
        If Not ok Then
            Assert.Fail("FragmentationException was expected but not thrown for a missing schema in the message body.")
        Else
            Debug.Print("Success: correct FragmentationException was thrown.")
        End If

    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErrorneousSchema2()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH BAD SCHEMA IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... bad schema")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", "this won't go for a schema")

        Dim target As xPLFragmentedMsg
        Dim ok As Boolean = False
        Try
            target = New xPLFragmentedMsg(msg, xDev)
        Catch ex As xPLFragmentedMsg.FragmentationException
            ok = True
        End Try
        If Not ok Then
            Assert.Fail("FragmentationException was expected but not thrown for a bad schema in the message body.")
        Else
            Debug.Print("Success: correct FragmentationException was thrown.")
        End If

    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErrorneousPartid1()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH BAD SCHEMA IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... missing schema")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        'msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", "some.schema")

        Dim target As xPLFragmentedMsg
        Dim ok As Boolean = False
        Try
            target = New xPLFragmentedMsg(msg, xDev)
        Catch ex As xPLFragmentedMsg.FragmentationException
            ok = True
        End Try
        If Not ok Then
            Assert.Fail("FragmentationException was expected but not thrown for a missing partid key.")
        Else
            Debug.Print("Success: correct FragmentationException was thrown.")
        End If
    End Sub

    <TestMethod()> _
    Public Sub TestConstructorErrorneousPartid2()
        ' - bad structure; no schema, erroneous schema, no partid, or bad partid

        Debug.Print("")
        Debug.Print("TESTING CASE WITH BAD PARTID IN BODY")
        Debug.Print("")

        ' second test a message received
        Debug.Print("Testing a message received... bad partid")
        Dim msg As New xPLMessage
        msg.MsgType = xPL_Base.xPLMessageTypeEnum.Command
        msg.Target = xDev.Address
        msg.Source = yDev.Address
        msg.Hop = 50
        msg.Schema = "fragment.basic"
        msg.KeyValueList.Clear()
        msg.KeyValueList.Add("partid", "1/2:35")
        msg.KeyValueList.Add("schema", "some.schema")

        ' set bad values and test
        msg.KeyValueList("partid") = "/2:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "x/2:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/x:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/2:"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "12:35"
        PartidSubTest(msg)
        msg.KeyValueList("partid") = "1/235"
        PartidSubTest(msg)
        msg.KeyValueList.Remove(msg.KeyValueList.IndexOf("partid"))
        PartidSubTest(msg)
        Debug.Print("Success: correct exceptions thrown for bad partids")
    End Sub
    Private Sub PartidSubTest(ByVal msg As xPLMessage)
        Dim target As xPLFragmentedMsg
        Try
            target = New xPLFragmentedMsg(msg, xDev) ' create message from 1st fragment
            If msg.KeyValueList.IndexOf("partid") <> -1 Then
                Assert.Fail("Exception expected but not thrown for message with bad partid; '" & msg.KeyValueList("partid") & "'.")
            Else
                Assert.Fail("Exception expected but not thrown for message with missing partid.")
            End If
        Catch ex As xPLFragmentedMsg.FragmentationException
            If msg.KeyValueList.IndexOf("partid") <> -1 Then
                Debug.Print("Bad partid '" & msg.KeyValueList("partid") & "' threw correct exception.")
            Else
                Debug.Print("Missing partid threw correct exception.")
            End If
        Catch ex As AssertFailedException
            Throw
        Catch ex As Exception
            Debug.Print("Got exception: " & ex.ToString)
            Assert.Fail("Wrong exception, expected a FragmentationException for a bad partid.")
        End Try
    End Sub
End Class
