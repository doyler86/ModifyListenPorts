# Functions for doing XML stuff with Saxon
#
# 20141205 - Jay MacDonald

# Define additional namespaces that may be needed
NAMESPACE="$NAMESPACE xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\""

if [ -z $JAVA_HOME ] ; then

       JAVA_HOME=${NEW_JAVA_HOME}
fi

# DO NOT USE saxonHE-9.6.0-9.6.0.2. The optimizations in 9.6 broke relative
# xpath with predicates.
SAXON="${DIR}/lib/xml/Saxon/saxonHE-9.5.1.8.jar"

# Call saxon to calculate an XPath from a file
# Expect $1 to be the file, $2 to be the xpath
xpath () {
	local FILE=$1
	local XPATH=$2

  cat <<EOF > /tmp/$$.xslt
  <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" $NAMESPACE>
    <xsl:output omit-xml-declaration="yes" />
    <xsl:template match="/">
      <xsl:for-each select="$XPATH"><xsl:value-of select='.' /><xsl:text></xsl:text></xsl:for-each>
    </xsl:template>
  </xsl:stylesheet>
EOF

	$JAVA_HOME/bin/java -jar $SAXON -s:$FILE -xsl:/tmp/$$.xslt -o:/tmp/$$.result

	RESULTS=`cat /tmp/$$.result`

	rm -f /tmp/$$.xslt
        rm -f /tmp/$$.result

	echo $RESULTS
}

# Expect $1 to be the file, $2 to be the xpath
xpath-copyof () {
        local FILE=$1
        local XPATH=$2

  cat <<EOF > /tmp/$$.xslt
  <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" $NAMESPACE>
    <xsl:output omit-xml-declaration="yes" />
    <xsl:template match="/">
      <xsl:for-each select="$XPATH"><xsl:copy-of select='.' /><xsl:text></xsl:text></xsl:for-each>
    </xsl:template>
  </xsl:stylesheet>
EOF

        $JAVA_HOME/bin/java -jar $SAXON -s:$FILE -xsl:/tmp/$$.xslt -o:/tmp/$$.result

        RESULTS=`cat /tmp/$$.result`

       rm -f /tmp/$$.xslt
       rm -f /tmp/$$.result

        echo "$RESULTS"
}
##################################

xpath-transform () {

        local FILE=$1
        local XSL_FILE=$2
      

        $JAVA_HOME/bin/java -jar $SAXON -s:$FILE -xsl:$XSL_FILE -o:$FILE

   
}

   xpath-transform-uri () {

        local FILE=$1
        local NEW_URI=$2
          

        cat <<EOF > /tmp/$$.xslt
         <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:l7="http://ns.l7tech.com/2010/04/gateway-management">
                 <xsl:output indent="yes"/>
                  <xsl:template match="node()|@*">
                   <xsl:copy>
                     <xsl:apply-templates select="node()|@*"/>
                   </xsl:copy>
                 </xsl:template>
                   <xsl:template match="/l7:Service/l7:ServiceDetail/l7:ServiceMappings/l7:HttpMapping/l7:UrlPattern">
                       <l7:UrlPattern>${NEW_URI}</l7:UrlPattern>
                   </xsl:template>
           </xsl:stylesheet>
              
EOF


        $JAVA_HOME/bin/java -jar $SAXON -s:$FILE -xsl:/tmp/$$.xslt -o:$FILE

        rm -f /tmp/$$.xslt
	rm -f /tmp/$$.result


}


