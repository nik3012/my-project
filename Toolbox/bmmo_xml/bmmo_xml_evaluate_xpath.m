function nodeValue = bmmo_xml_evaluate_xpath(xmlFile, xpathStr)
% Evaluate the xpath expression defined in "xpathStr" on the XML document
% specified by "xmlFile"

import javax.xml.xpath.*

% Create an XPath expression.
factory    = XPathFactory.newInstance();
xpath      = factory.newXPath;
expression = xpath.compile(xpathStr);

% Apply the expression to the DOM.
xmlFile    = bmmo_create_full_file_path(xmlFile);
document   = xmlread(xmlFile);
nodeList   = expression.evaluate(document, XPathConstants.NODESET);

% Iterate through the nodes that are returned.
nodeValue = cell(nodeList.getLength, 1);
for index = 1 : nodeList.getLength
    node                = nodeList.item(index - 1);
    nodeValue{index, 1} = char(node.getFirstChild.getNodeValue);
end

end