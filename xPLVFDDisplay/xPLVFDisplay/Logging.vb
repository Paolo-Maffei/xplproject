Imports System.IO

Public Class Logger

    Private LogFile As String = ""
    Private CurLogLevel As Integer = LogLevel.AppError
    Private objLogFile As StreamWriter
    Private LogisActive As Boolean = False

    'Log Level for Error Logging
    Public Enum LogLevel
        AppInfo = 1
        AppWarn = 2
        AppError = 3
        AppCrit = 4
    End Enum

    Property CurrentLogLevel() As Integer
        Get
            CurrentLogLevel = CurLogLevel
        End Get
        Set(ByVal value As Integer)
            CurLogLevel = value
        End Set
    End Property

    Property LogFilePath() As String
        Get
            LogFilePath = LogFile
        End Get
        Set(ByVal value As String)
            LogFile = value
        End Set
    End Property

    ReadOnly Property LoggingActive() As Boolean
        Get
            LoggingActive = LogisActive
        End Get
    End Property

    Public Sub StartLogging()
        If LogFile = "" Then
            LogFile = My.Computer.FileSystem.CurrentDirectory.ToString & "\xplvfd.log"

        End If

        LogisActive = True

        If Not File.Exists(LogFile) Then
            Try
                objLogFile = File.CreateText(LogFile)
            Catch ex As Exception
                Console.WriteLine("Cannot Create LogFile: " & LogFile)
                LogisActive = False
            End Try
        Else
            Try
                objLogFile = File.AppendText(LogFile)
            Catch ex As Exception
                Console.WriteLine("Cannot open Logfile for Writing: " & LogFile)
                LogisActive = False
            End Try
        End If

        If LogisActive Then
            AddLogEntry(LogLevel.AppInfo, "Started Logging.", True)
        End If

    End Sub

    Public Sub LogError(ByVal logtxt As String)
        Dim CurrentThreshold As Integer = CType(System.Enum.Parse(GetType(LogLevel), CurrentLogLevel), LogLevel)
        Dim ThisMessage As Integer = LogLevel.AppError

        If LogisActive Then
            If ThisMessage >= CurrentThreshold Then
                Dim timeStamp As String = Now.ToString
                objLogFile.WriteLine(timeStamp & ", " & logtxt & LogLevel.AppError.ToString)
            End If
        End If
    End Sub

    Public Sub AddLogEntry(ByVal loglvl As LogLevel, ByVal logtxt As String, Optional ByVal OverRideLevel As Boolean = False)
        Dim CurrentThreshold As Integer = CType(System.Enum.Parse(GetType(LogLevel), CurrentLogLevel), LogLevel)
        Dim ThisMessage As Integer = CType(System.Enum.Parse(GetType(LogLevel), loglvl), LogLevel)

        If LogisActive Then
            If ThisMessage >= CurrentThreshold Or OverRideLevel Then
                Dim timeStamp As String = Now.ToString
                objLogFile.WriteLine(timeStamp & ", " & loglvl.ToString & ", " & logtxt)
            End If
        End If
    End Sub

    Public Sub StopLogging()

        AddLogEntry(LogLevel.AppInfo, "Stopped Logging Engine.", True)

        Try
            objLogFile.Close()
        Catch ex As Exception
            Console.WriteLine("Error Closing Log File. Log Contents May be Lost.")
        End Try
        LogisActive = False

    End Sub

End Class
