<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
<xsl:template match="/">
  <xsl:apply-templates select="log"/>
</xsl:template>

<xsl:template match="log">
<html>
	<head>
		<title>xPL Messages</title>
	</head>
	<body bgcolor="#d4d0c8" style="FONT-SIZE: 10px; FONT-FAMILY: Arial, Helvetica, sans-serif">
		<TABLE cellSpacing="4" cellPadding="1" width="100%" border="0" bgcolor="#d4d0c8">
		<TR><TD><STRONG>Date/Time</STRONG></TD><TD><STRONG>Source</STRONG></TD><TD><STRONG>Type</STRONG></TD><TD><STRONG>Text</STRONG></TD><TD><STRONG>Code</STRONG></TD></TR>
			<xsl:apply-templates select="xplmsg"/>
		</TABLE>
	</body>
</html>

</xsl:template>

<xsl:template match="xplmsg">
  <xsl:if test="schema/class[translate(.,$lowercase,$uppercase)='LOG']">
			<TR>
				<TD>
					<xsl:value-of select="@logdate" />
				</TD>
				<TD>
				    <xsl:value-of select="header/source/vendor" />.<xsl:value-of select="header/source/device" />.<xsl:value-of select="header/source/instance" />
				</TD>
				<TD>
					<xsl:choose>
					<xsl:when test="schema/infopairs/info[translate(@name,$lowercase,$uppercase)='TYPE']/@value[translate(.,$lowercase,$uppercase)='ERR']">
					  <xsl:attribute name="bgcolor">#ff0000</xsl:attribute>
					</xsl:when>
					<xsl:when test="schema/infopairs/info[translate(@name,$lowercase,$uppercase)='TYPE']/@value[translate(.,$lowercase,$uppercase)='WRN']">
					  <xsl:attribute name="bgcolor">#ffff00</xsl:attribute>
					</xsl:when>
					</xsl:choose>
				  	<xsl:value-of select="schema/infopairs/info[translate(@name,$lowercase,$uppercase)='TYPE']/@value" />
				</TD>
				<TD>
				  	<xsl:value-of select="schema/infopairs/info[translate(@name,$lowercase,$uppercase)='TEXT']/@value" />
				</TD>
				<TD>
				  	<xsl:value-of select="schema/infopairs/info[translate(@name,$lowercase,$uppercase)='CODE']/@value" />
			    </TD>
			</TR>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
