<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:template match="/">
  <xsl:apply-templates select="log"/>
</xsl:template>

<xsl:template match="log">
<html>
	<head>
		<title>xPL Messages</title>
	</head>
	<body>
		<TABLE cellSpacing="1" cellPadding="1" border="0">
		<TR>
    <TD><STRONG>msgtype</STRONG></TD>
    <TD><STRONG>date/time</STRONG></TD>
    <TD><STRONG>source vendor</STRONG></TD>
    <TD><STRONG>source device</STRONG></TD>
    <TD><STRONG>source instance</STRONG></TD>
    <TD><STRONG>target vendor</STRONG></TD>
    <TD><STRONG>target device</STRONG></TD>
    <TD><STRONG>target instance</STRONG></TD>
    <TD><STRONG>class</STRONG></TD>
    <TD><STRONG>type</STRONG></TD>
    <TD><STRONG>name</STRONG></TD>
    <TD><STRONG>value</STRONG></TD>
   </TR>
			<xsl:apply-templates select="xplmsg"/>
  </TABLE>
	</body>
</html>

</xsl:template>

<xsl:template match="xplmsg">
   <TR>
    <TD><xsl:value-of select="header/msgtype" /></TD>
    <TD><xsl:value-of select="@logdate" /></TD>
    <TD><xsl:value-of select="header/source/vendor" /></TD>
    <TD><xsl:value-of select="header/source/device" /></TD>
    <TD><xsl:value-of select="header/source/instance" /></TD>
    <TD><xsl:value-of select="header/target/vendor" /></TD>
    <TD><xsl:value-of select="header/target/device" /></TD>
    <TD><xsl:value-of select="header/target/instance" /></TD>
    <TD><xsl:value-of select="schema/class" /></TD>
    <TD><xsl:value-of select="schema/type" /></TD>
    <TD></TD>
    <TD></TD>
   </TR>
    <xsl:apply-templates select="schema/infopairs/info"/>
</xsl:template>

<xsl:template match="schema/infopairs/info">
   <TR>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD></TD>
    <TD><xsl:value-of select="@name" /></TD>
    <TD><xsl:value-of select="@value" /></TD>
   </TR>
</xsl:template>

</xsl:stylesheet>
