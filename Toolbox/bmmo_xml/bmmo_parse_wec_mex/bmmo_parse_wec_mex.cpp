#include "mex.h"
#include "rapidxml/rapidxml.hpp"
#include <iostream>
#include <fstream>
#include <vector>
#include <stdio.h>
#include <string.h>

using namespace std;
using namespace rapidxml;

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

	xml_document<> doc;
	xml_node<> * root_node;
    int node_count = 0;
    char *input_buf;
    size_t buflen;
    double *xy, *dxy;
    mxLogical *valid;
    
    /* get the length of the input string */
    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

    /* copy the string data from prhs[0] into a C string input_ buf.    */
    input_buf = mxArrayToString(prhs[0]);
    
    //printf("Input filename = %s\n", input_buf);

	// Read the xml file into a vector
    //printf("Reading WEC file into vector\n");
        
    ifstream theFile (input_buf);
	vector<char> buffer((istreambuf_iterator<char>(theFile)), istreambuf_iterator<char>());
	buffer.push_back('\0');
    theFile.close();
    
    //printf("Parsing XML buffer\n");
	// Parse the buffer using the xml file parsing library into doc 
	doc.parse<0>(&buffer[0]);
	// Find our root node
    //    printf("Locating Root node\n");
    
	root_node = doc.first_node("ADELwaferErrorCorrection:Report");
    
    //printf("Locating TargetList node\n");
    xml_node<> * tlist_node = root_node->first_node("ErrorCorrectionData")->first_node("TargetList");
      
    //printf("Iterating over element nodes\n");
	for (xml_node<> * elt_node = tlist_node->first_node("elt"); elt_node; elt_node = elt_node->next_sibling())
	{
        node_count++;
    }
    //printf("%d element nodes found\n", node_count);
    
    /* Create matrices for the return arguments. */
    //printf("Allocating output matrices\n");
    plhs[0] = mxCreateDoubleMatrix((mwSize)node_count, (mwSize)2, mxREAL);
    plhs[1] = mxCreateDoubleMatrix((mwSize)node_count, (mwSize)2, mxREAL);
    plhs[2] = mxCreateLogicalMatrix((mwSize)node_count, (mwSize)2);
    xy = mxGetPr(plhs[0]);
    dxy = mxGetPr(plhs[1]);
    valid = mxGetLogicals(plhs[2]);
    
    //printf("Iterating over element nodes\n");
    int index = 0;
    xml_node<> * x_node;
	for (xml_node<> * elt_node = tlist_node->first_node("elt"); elt_node; elt_node = elt_node->next_sibling())
	{
        x_node = elt_node->first_node("NominalPosition")->first_node("X");
        //printf("x_node value is %s\n", x_node->value());
        xy[index] = atof(x_node->value());
        x_node = elt_node->first_node("NominalPosition")->first_node("Y");
        //printf("y_node value is %s\n", x_node->value());
        xy[index + node_count] = atof(x_node->value());
        
        x_node = elt_node->first_node("PositionError")->first_node("X");
        //printf("x_node value is %s\n", x_node->value());
        dxy[index] = atof(x_node->value());
        x_node = elt_node->first_node("PositionError")->first_node("Y");
        //printf("y_node value is %s\n", x_node->value());
        dxy[index + node_count] = atof(x_node->value());
        
        x_node = elt_node->first_node("ErrorValidity")->first_node("X");
        //printf("x_node value is %s\n", x_node->value());
        valid[index] = (strcmp(x_node->value(), "true") == 0);
        x_node = elt_node->first_node("ErrorValidity")->first_node("Y");
        //printf("y_node value is %s\n", x_node->value());
        valid[index + node_count] = (strcmp(x_node->value(), "true") == 0);
        
        index++;
    }
    
    doc.clear();
}