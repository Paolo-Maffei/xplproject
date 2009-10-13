Option Strict On

Imports System.Math

Public Class sunrise

    ' -- The following properties are exposed:
    'Sunrise (r) - Sunrise time
    'Sunset (r) - Sunset time
    'Longitude (r/w) - Longitude to calculate for
    'Latitude (r/w) - Latitude to calculate for
    'DateDay (r/w) - Date to calculate for
    '
    '
    ' -- The following method is exposed
    'CalculateSun - Calculate sunrise, sunset
    '
    '
    ' Original: Scott Seligman <scott@scottandmichelle.net>
    ' Ported to VB.Net: Tom Van den Panhuyzen <tomvdp@gmail.com>

    Private m_nLongitude As Double
    Private m_nLatitude As Double
    Private m_dateSel As Date

    Private m_dateSunrise As Date
    Private m_dateSunset As Date

    Private m_bCalculated As Boolean
    Private m_dateCalculatedDay As Date

    Public Sub New()
        m_dateSel = DateTime.SpecifyKind(Date.Today, DateTimeKind.Utc)  'somehow ToLocalTime does not work correctly without this
        m_bCalculated = False
    End Sub

    Public ReadOnly Property Sunrise() As Date
        Get
            If Not m_bCalculated Then
                CalculateSun()
            End If
            Return m_dateSunrise.ToLocalTime()
        End Get
    End Property

    Public ReadOnly Property Sunrise(ByVal thisDay As Date) As Date
        Get
            DateDay = thisDay
            Return Me.Sunrise()
        End Get
    End Property

    Public ReadOnly Property Sunset() As Date
        Get
            If Not m_bCalculated Then
                CalculateSun()
            End If
            Return m_dateSunset.ToLocalTime()
        End Get
    End Property

    Public ReadOnly Property Sunset(ByVal thisDay As Date) As Date
        Get
            DateDay = thisDay
            Return Me.Sunset()
        End Get
    End Property

    Public Property Longitude() As Double
        Set(ByVal nNew As Double)
            If m_nLongitude <> nNew Then
                m_bCalculated = False
            End If
            m_nLongitude = nNew
        End Set
        Get
            Return m_nLongitude
        End Get
    End Property

    Public Property Latitude() As Double
        Set(ByVal nNew As Double)
            If m_nLatitude <> nNew Then
                m_bCalculated = False
            End If
            m_nLatitude = nNew
        End Set
        Get
            Return m_nLatitude
        End Get
    End Property

    Public Property DateDay() As Date
        Set(ByVal dateNew As Date)
            If m_dateCalculatedDay <> dateNew Then
                m_bCalculated = False
            End If
            m_dateSel = DateTime.SpecifyKind(dateNew, DateTimeKind.Utc)  'somehow ToLocalTime does not work correctly without this
        End Set
        Get
            Return m_dateSel
        End Get
    End Property

    Private Function RadToDeg(ByVal angleRad As Double) As Double
        Return 180 * angleRad / Math.PI
    End Function

    Private Function DegToRad(ByVal angleDeg As Double) As Double
        Return Math.PI * angleDeg / 180
    End Function

    Private Function calcJD(ByVal nYear As Integer, ByVal nMonth As Integer, ByVal nDay As Integer) As Double
        If nMonth <= 2 Then
            nYear = nYear - 1
            nMonth = nMonth + 12
        End If
        Dim A As Integer
        Dim B As Integer

        A = nYear \ 100
        B = 2 - A + A \ 4

        Return Int(365.25 * (nYear + 4716)) + Int(30.6001 * (nMonth + 1)) + nDay + B - 1524.5
    End Function

    Private Function calcTimeJulianCent(ByVal njd As Double) As Double
        Return (njd - 2451545.0#) / 36525.0#
    End Function

    Private Function calcJDFromJulianCent(ByVal nt As Double) As Double
        Return nt * 36525.0# + 2451545.0#
    End Function

    Private Function calcGeomMeanLongSun(ByVal nt As Double) As Double
        Dim nLO As Double
        nLO = 280.46646 + nt * (36000.76983 + 0.0003032 * nt)
        Do While nLO > 360.0#
            nLO = nLO - 360.0#
        Loop
        Do While nLO < 0
            nLO = nLO + 360.0#
        Loop
        Return nLO
    End Function

    Private Function calcGeomMeanAnomalySun(ByVal nt As Double) As Double
        Return 357.52911 + nt * (35999.05029 - 0.0001537 * nt)
    End Function

    Private Function calcEccentricityEarthOrbit(ByVal nt As Double) As Double
        Return 0.016708634 - nt * (0.000042037 + 0.0000001267 * nt)
    End Function

    Private Function calcSunEqOfCenter(ByVal nt As Double) As Double
        Dim nm As Double
        Dim nmrad As Double
        Dim nsinm As Double
        Dim nsin2m As Double
        Dim nsin3m As Double

        nm = calcGeomMeanAnomalySun(nt)

        nmrad = DegToRad(nm)
        nsinm = Sin(nmrad)
        nsin2m = Sin(nmrad + nmrad)
        nsin3m = Sin(nmrad + nmrad + nmrad)

        Return nsinm * (1.914602 - nt * (0.004817 + 0.000014 * nt)) + nsin2m * (0.019993 - 0.000101 * nt) + nsin3m * 0.000289
    End Function

    Private Function calcSunTrueLong(ByVal nt As Double) As Double
        Dim n10 As Double
        Dim nc As Double

        n10 = calcGeomMeanLongSun(nt)
        nc = calcSunEqOfCenter(nt)

        Return n10 + nc
    End Function

    Private Function calcSunApparentLong(ByVal nt As Double) As Double
        Dim no As Double
        Dim nomega As Double

        no = calcSunTrueLong(nt)
        nomega = 125.04 - 1934.136 * nt
        Return no - 0.00569 - 0.00478 * Sin(DegToRad(nomega))
    End Function

    Private Function calcMeanObliquityOfEcliptic(ByVal nt As Double) As Double
        Dim nseconds As Double

        nseconds = 21.448 - nt * (46.815 + nt * (0.00059 - nt * (0.001813)))
        Return 23.0# + (26.0# + (nseconds / 60.0#)) / 60.0#
    End Function

    Private Function calcObliquityCorrection(ByVal nt As Double) As Double
        Dim ne0 As Double
        ne0 = calcMeanObliquityOfEcliptic(nt)

        Dim nomega As Double
        nomega = 125.04 - 1934.136 * nt
        Return ne0 + 0.00256 * Cos(DegToRad(nomega))
    End Function

    Private Function calcSunDeclination(ByVal nt As Double) As Double
        Dim ne As Double
        Dim nlambda As Double
        Dim nsint As Double

        ne = calcObliquityCorrection(nt)
        nlambda = calcSunApparentLong(nt)

        nsint = Sin(DegToRad(ne)) * Sin(DegToRad(nlambda))
        Return RadToDeg(Asin(nsint))
    End Function

    Private Function calcEquationOfTime(ByVal nt As Double) As Double
        Dim nepsilon As Double
        Dim nl0 As Double
        Dim ne As Double
        Dim nm As Double
        Dim ny As Double
        Dim nsin2l0 As Double
        Dim nsinm As Double
        Dim ncos2l0 As Double
        Dim nsin4l0 As Double
        Dim nsin2m As Double
        Dim nEtime As Double

        nepsilon = calcObliquityCorrection(nt)
        nl0 = calcGeomMeanLongSun(nt)
        ne = calcEccentricityEarthOrbit(nt)
        nm = calcGeomMeanAnomalySun(nt)

        ny = Math.Tan(DegToRad(nepsilon) / 2.0#)
        ny = ny * ny

        nsin2l0 = Sin(2.0# * DegToRad(nl0))
        nsinm = Sin(DegToRad(nm))
        ncos2l0 = Cos(2.0# * DegToRad(nl0))
        nsin4l0 = Sin(4.0# * DegToRad(nl0))
        nsin2m = Sin(2.0# * DegToRad(nm))

        nEtime = ny * nsin2l0 - 2.0# * ne * nsinm + 4.0# * ne * _
            ny * nsinm * ncos2l0 - 0.5 * ny * ny * nsin4l0 - _
            1.25 * ne * ne * nsin2m

        Return RadToDeg(nEtime) * 4.0#
    End Function

    Private Function calcHourAngleSunrise(ByVal nlat As Double, ByVal nsolarDec As Double) As Double
        Dim nlatRad As Double
        Dim nsdRad As Double
        Dim nHAarg As Double
        Dim nHA As Double

        nlatRad = DegToRad(nlat)
        nsdRad = DegToRad(nsolarDec)

        nHAarg = (Cos(DegToRad(90.833)) / (Cos(nlatRad) * Cos(nsdRad)) - Tan(nlatRad) * Tan(nsdRad))

        Dim nTemp As Double
        nTemp = Cos(DegToRad(90.833)) / (Cos(nlatRad) * Cos(nsdRad)) - Tan(nlatRad) * Tan(nsdRad)
        If Abs(nTemp) > 1 Then
            nHA = -999
        Else
            nHA = (Acos(nTemp))
        End If

        Return nHA
    End Function

    Private Function calcHourAngleSunset(ByVal nlat As Double, ByVal nsolarDec As Double) As Double
        Dim nlatRad As Double
        Dim nsdRad As Double
        Dim nHAarg As Double
        Dim nHA As Double

        nlatRad = DegToRad(nlat)
        nsdRad = DegToRad(nsolarDec)

        nHAarg = (Cos(DegToRad(90.833)) / (Cos(nlatRad) * Cos(nsdRad)) - Tan(nlatRad) * Tan(nsdRad))

        Dim nTemp As Double
        nTemp = Cos(DegToRad(90.833)) / (Cos(nlatRad) * Cos(nsdRad)) - Tan(nlatRad) * Tan(nsdRad)
        If Abs(nTemp) > 1 Then
            nHA = 999
        Else
            nHA = (Acos(nTemp))
        End If

        Return -nHA
    End Function

    Private Function calcSunriseUTC(ByVal njd As Double, ByVal nLatitude As Double, ByVal nLongitude As Double) As Double
        Dim nt As Double
        Dim neqTime As Double
        Dim nsolarDec As Double
        Dim nhourAngle As Double

        Dim ndelta As Double
        Dim ntimeDiff As Double
        Dim ntimeUTC As Double

        nt = calcTimeJulianCent(njd)

        neqTime = calcEquationOfTime(nt)
        nsolarDec = calcSunDeclination(nt)
        nhourAngle = calcHourAngleSunrise(nLatitude, nsolarDec)
        If nhourAngle = -999 Then
            Return -999
        End If

        ndelta = nLongitude - RadToDeg(nhourAngle)
        ntimeDiff = 4 * ndelta
        ntimeUTC = 720 + ntimeDiff - neqTime

        Dim nnewt As Double
        nnewt = calcTimeJulianCent(calcJDFromJulianCent(nt) + ntimeUTC / 1440.0#)
        neqTime = calcEquationOfTime(nnewt)
        nsolarDec = calcSunDeclination(nnewt)
        nhourAngle = calcHourAngleSunrise(nLatitude, nsolarDec)
        If nhourAngle = -999 Then
            Return -999
        End If
        ndelta = nLongitude - RadToDeg(nhourAngle)
        ntimeDiff = 4 * ndelta
        ntimeUTC = 720 + ntimeDiff - neqTime

        Return ntimeUTC
    End Function

    Private Function calcSunsetUTC(ByVal njd As Double, ByVal nLatitude As Double, ByVal nLongitude As Double) As Double
        Dim neqTime As Double
        Dim nsolarDec As Double
        Dim nhourAngle As Double

        Dim ndelta As Double
        Dim ntimeDiff As Double
        Dim ntimeUTC As Double
        Dim nnewt As Double
        Dim nt As Double

        nt = calcTimeJulianCent(njd)

        neqTime = calcEquationOfTime(nt)
        nsolarDec = calcSunDeclination(nt)
        nhourAngle = calcHourAngleSunset(nLatitude, nsolarDec)
        If nhourAngle = -999 Then
            Return -999
        End If

        ndelta = nLongitude - RadToDeg(nhourAngle)
        ntimeDiff = 4 * ndelta
        ntimeUTC = 720 + ntimeDiff - neqTime

        nnewt = calcTimeJulianCent(calcJDFromJulianCent(nt) + ntimeUTC / 1440.0#)
        neqTime = calcEquationOfTime(nnewt)
        nsolarDec = calcSunDeclination(nnewt)
        nhourAngle = calcHourAngleSunset(nLatitude, nsolarDec)
        If nhourAngle = -999 Then
            Return -999
        End If

        ndelta = nLongitude - RadToDeg(nhourAngle)
        ntimeDiff = 4 * ndelta
        ntimeUTC = 720 + ntimeDiff - neqTime

        Return ntimeUTC
    End Function

    Private Sub CalculateSun()
        Dim nLatitude As Double
        Dim nLongitude As Double
        nLatitude = m_nLatitude
        nLongitude = m_nLongitude

        If nLatitude >= -90 And nLatitude < -89.5 Then
            nLatitude = -89.5
        End If
        If nLatitude <= 90 And nLatitude > 89.8 Then
            nLatitude = 89.8
        End If

        Dim njd As Double

        njd = calcJD(m_dateSel.Year, m_dateSel.Month, m_dateSel.Day)

        'Calculate sunrise
        Dim nRiseTimeGMT As Double
        nRiseTimeGMT = calcSunriseUTC(njd, nLatitude, nLongitude)

        If nRiseTimeGMT = -999 Then
            m_dateSunrise = m_dateSel
        Else
            m_dateSunrise = m_dateSel.AddSeconds(60 * nRiseTimeGMT)
        End If

        'Calculate sunset
        Dim nSetTimeGMT As Double
        nSetTimeGMT = calcSunsetUTC(njd, nLatitude, nLongitude)
        If nSetTimeGMT = -999 Then
            m_dateSunset = m_dateSel
        Else
            m_dateSunset = m_dateSel.AddSeconds(60 * nSetTimeGMT)
        End If

        m_bCalculated = True
        m_dateCalculatedDay = m_dateSel
    End Sub
End Class
