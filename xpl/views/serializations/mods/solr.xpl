<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2012 Ethan Gruber	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/mods/solr.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
