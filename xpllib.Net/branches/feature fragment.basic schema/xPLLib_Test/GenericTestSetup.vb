Option Strict On

Imports System
Imports System.Text
Imports System.Collections.Generic
Imports Microsoft.VisualStudio.TestTools.UnitTesting
Imports xPL
Imports xPL.xPL_Base
Imports System.Diagnostics

''' <summary>
''' Contains procedures, functions adn globals for test setup of devices, device lists and other functions
''' </summary>
''' <remarks></remarks>
Module GenericTestSetup
    ''' <summary>
    ''' The name for a key the <see cref="WaitForTestKey">WaitForTestKey function</see> will wait for. Add this 
    ''' key to a message with value 'x' adn send it. Using the WaitForTestKey you can now wait for a message 
    ''' with that key and the value 'x' to arrive and continue your test from there.
    ''' </summary>
    ''' <remarks></remarks>
    Friend Const TESTKEY As String = "testkey"
    ''' <summary>
    ''' First test device created and up and running before each test, see also yDev, the second test device
    ''' </summary>
    ''' <remarks></remarks>
    Friend WithEvents xDev As xPLDevice
    ''' <summary>
    ''' Second test device created and up and running before each test, see also xDev, the first test device
    ''' </summary>
    ''' <remarks></remarks>
    Friend WithEvents yDev As xPLDevice
    ''' <summary>
    ''' List where the messages received by xDev will be stored, WaitForTestKey will look here for arrived messages
    ''' </summary>
    ''' <remarks></remarks>
    Friend xMessageList As Collection   ' messages received will be stored here, key is the msg value TestKey
    ''' <summary>
    ''' List where the messages received by yDev will be stored, WaitForTestKey will look here for arrived messages
    ''' </summary>
    ''' <remarks></remarks>
    Friend yMessageList As Collection   ' messages received will be stored here, key is the msg value TestKey

    ''' <summary>
    ''' Test initializer, call this from your unittest initialization routine (a sub with property TestInitialize() set)
    ''' </summary>
    ''' <remarks></remarks>
    Friend Sub xPLTestInitialize()
        xDev = New xPLDevice
        yDev = New xPLDevice
        xMessageList = New Collection
        yMessageList = New Collection

        Dim x As Integer = 0
        xDev.Address = "tieske-libtest.xdev"
        yDev.Address = "tieske-libtest.ydev"
        xDev.Configurable = False
        yDev.Configurable = False
        xDev.MessagePassing = MessagePassingEnum.PassOthersHeartbeats
        yDev.MessagePassing = MessagePassingEnum.PassOthersHeartbeats
        xDev.AutoFragment = True
        yDev.AutoFragment = True
        xPLListener.ByPassHub = False
        AddHandler xDev.xPLMessageReceived, AddressOf MessageReceived
        AddHandler yDev.xPLMessageReceived, AddressOf MessageReceived

        xDev.Enable()
        yDev.Enable()
        Debug.Print("")
        Debug.Print("Test devices xDev (tieske-libtest.xdev) and yDev (tieske-libtest.ydev) enabled")
        ' wait for going online, max 5 seconds
        While (xDev.Status <> xPLDeviceStatus.Online Or yDev.Status <> xPLDeviceStatus.Online) And x < 50
            Threading.Thread.Sleep(100)
            x = x + 1
        End While
        Assert.IsTrue(x < 50, "Devices not online within 5 seconds, test aborted")
        Debug.Print("Both online, commencing test")
        Debug.Print("")
    End Sub

    ''' <summary>
    ''' Test finalizer fro cleanup, call this from your unittest initialization routine (a sub with property TestCleanup() set)
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub xPLTestCleanup()
        Debug.Print("")
        Debug.Print("Test finished, now destroying xDev and yDev devices.")
        If Not xDev Is Nothing Then
            RemoveHandler xDev.xPLMessageReceived, AddressOf MessageReceived
            xDev.Dispose()
            xDev = Nothing
        End If
        If Not xMessageList Is Nothing Then
            xMessageList.Clear()
            xMessageList = Nothing
        End If
        If Not yDev Is Nothing Then
            RemoveHandler yDev.xPLMessageReceived, AddressOf MessageReceived
            yDev.Dispose()
            yDev = Nothing
        End If
        If Not yMessageList Is Nothing Then
            yMessageList.Clear()
            yMessageList = Nothing
        End If
        Debug.Print("Done.")
    End Sub

    ''' <summary>
    ''' Stores received messages in the xMessageList or yMessageList, where the <see cref="WaitForTestKey">WaitForTestKey function</see> 
    ''' will look for the defined testkey.
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Private Sub MessageReceived(ByVal sender As xPLDevice, ByVal e As xPLDevice.xPLEventArgs)
        If e.XplMsg.KeyValueList.IndexOf(TESTKEY) <> -1 Then
            Dim v As String = e.XplMsg.KeyValueList(TESTKEY)
            If sender Is xDev Then
                xMessageList.Add(e.XplMsg, v)
            End If
            If sender Is yDev Then
                yMessageList.Add(e.XplMsg, v)
            End If
        End If
    End Sub
    ''' <summary>
    ''' Wait for a message to arrive with a specific <see cref="TESTKEY">testkey</see>, returns that message, or Nothing if it times out
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="TestKeyValue"></param>
    ''' <param name="TimeOut">Timeout in milliseconds</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Friend Function WaitForTestKey(ByVal sender As xPLDevice, ByVal TestKeyValue As String, Optional ByVal TimeOut As Integer = 5000) As xPLMessage
        Dim n As Integer = 0
        Dim Done As Boolean = False
        Dim result As xPLMessage = Nothing
        While Not Done
            Threading.Thread.Sleep(100)
            n = n + 100
            If sender Is xDev Then
                Done = xMessageList.Contains(TestKeyValue)
                If Done Then result = CType(xMessageList(TestKeyValue), xPLMessage)
            End If
            If sender Is yDev Then
                Done = yMessageList.Contains(TestKeyValue)
                If Done Then result = CType(yMessageList(TestKeyValue), xPLMessage)
            End If
            If Not Done And n > TimeOut Then
                Done = True ' timeout, 'Nothing is returned
            End If
        End While
        Return result
    End Function

End Module
