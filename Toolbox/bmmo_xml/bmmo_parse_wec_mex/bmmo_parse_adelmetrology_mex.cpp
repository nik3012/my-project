#include "mex.h"
#include "rapidxml/rapidxml.hpp"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>
#include <stdio.h>
#include <string.h>

using namespace std;
using namespace rapidxml;

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

	xml_document<> doc;
	xml_node<> * root_node;
    int wafer_count = 0;
    int mark_count = 0;
    mwSize label_count = 0;
    char *input_buf;
    size_t buflen;
    double *xc, *yc, *xf, *yf, *dx, *dy, *labels;
    mxLogical *validx, *validy;
    
    
    /* get the length of the input string */
    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

    /* copy the string data from prhs[0] into a C string input_ buf.    */
    input_buf = mxArrayToString(prhs[0]);
    
    //printf("Input filename = %s\n", input_buf);

	// Read the xml file into a vector
    //printf("Reading ADELmetrology file into vector\n");
        
    ifstream theFile (input_buf);
	vector<char> buffer((istreambuf_iterator<char>(theFile)), istreambuf_iterator<char>());
	buffer.push_back('\0');
    theFile.close();
    
    //printf("Parsing XML buffer\n");
	// Parse the buffer using the xml file parsing library into doc 
	doc.parse<0>(&buffer[0]);
	
    // Find our root node    
    //printf("Locating Root node\n");
	root_node = doc.first_node("ADELmetrology:MetrologyReport");
    if(root_node == 0)
    {        
     printf("ADELmetrology:MetrologyReport not found. Trying MetrologyReport\n");   
     root_node = doc.first_node("MetrologyReport");
     if(root_node == 0)
     {
      printf("bmmo_parse_adelmetrology_mex error: XML root node not found\n");
      exit(0);
     }
    }
        
    // Find the creation date
    //printf("Reading date\n");
    string datestring;
    datestring = root_node->first_node("Header")->first_node("CreateTime")->value();
    
    //printf("Locating WaferResultList node\n");
    xml_node<> * wafer_result_list = root_node->first_node("Results")->first_node("WaferResultList");
      
    //printf("Counting wafer nodes\n");
    
	for (xml_node<> * wafer_node = wafer_result_list->first_node("WaferResult"); wafer_node; wafer_node = wafer_node->next_sibling())
	{
        wafer_count++;
    }
    //printf("%d wafers found\n", wafer_count);
    
    //printf("Counting marks and target labels \n");
    xml_node<> * wafer = wafer_result_list->first_node("WaferResult");
    map<string, int> targetlabels;
    string this_label;
    map<string, int>::const_iterator found;
    for(xml_node<> * measurement = wafer->first_node("MeasurementList")->first_node("Measurement"); measurement; measurement = measurement->next_sibling())
	{
        mark_count++;
        this_label = measurement->first_node("RecipeTargetId")->first_node("TargetLabel")->value();
        found = targetlabels.find(this_label);
        if (found == targetlabels.end())
        {
           label_count ++;
           targetlabels.insert(pair<string, int>(this_label, label_count));
        }
    }
    //printf("%d marks found\n", mark_count);
    //printf("%d unique target labels found\n", label_count);
    
    /* Create matrices for the return arguments. */
    //printf("Allocating output matrices\n");
    // xc, yc, xf, yf
    plhs[0] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)1, mxREAL);
    plhs[3] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)1, mxREAL);
    plhs[4] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)1, mxREAL);
    // dx, dy, valid:
    plhs[5] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)wafer_count, mxREAL);
    plhs[6] = mxCreateDoubleMatrix((mwSize)mark_count, (mwSize)wafer_count, mxREAL);
    plhs[7] = mxCreateLogicalMatrix((mwSize)mark_count, (mwSize)wafer_count);
    plhs[8] = mxCreateLogicalMatrix((mwSize)mark_count, (mwSize)wafer_count);
    // 
    plhs[9] = mxCreateCellArray(1, &label_count);
    plhs[10] = mxCreateString(datestring.c_str());
    
    for(found = targetlabels.begin(); found != targetlabels.end(); found++)
    {   
        mxSetCell(plhs[9], found->second - 1, mxCreateString(found->first.c_str()));
    }
    
    xc = mxGetPr(plhs[0]);
    yc = mxGetPr(plhs[1]);
    xf = mxGetPr(plhs[2]);
    yf = mxGetPr(plhs[3]);
    labels = mxGetPr(plhs[4]);
    dx = mxGetPr(plhs[5]);
    dy = mxGetPr(plhs[6]);
    validx = mxGetLogicals(plhs[7]);
    validy = mxGetLogicals(plhs[8]);
    
    int index = 0;
    for(xml_node<> * measurement = wafer->first_node("MeasurementList")->first_node("Measurement"); measurement; measurement = measurement->next_sibling())
	{
        this_label = measurement->first_node("RecipeTargetId")->first_node("TargetLabel")->value();
        found = targetlabels.find(this_label);
        labels[index] = found->second;
        xc[index] = atof(measurement->first_node("FieldPosition")->first_node("X")->value()); 
        yc[index] = atof(measurement->first_node("FieldPosition")->first_node("Y")->value());
        xf[index] = atof(measurement->first_node("TargetPosition")->first_node("X")->value());
        yf[index] = atof(measurement->first_node("TargetPosition")->first_node("Y")->value());
        
        dx[index] = atof(measurement->first_node("OverlayMeasurement")->first_node("Overlay")->first_node("X")->value());
        dy[index] = atof(measurement->first_node("OverlayMeasurement")->first_node("Overlay")->first_node("Y")->value());
        validx[index] = (strcmp(measurement->first_node("OverlayMeasurement")->first_node("Valid")->first_node("X")->value(), "true") == 0);
        validy[index] = (strcmp(measurement->first_node("OverlayMeasurement")->first_node("Valid")->first_node("Y")->value(), "true") == 0);        
        index ++;
    }
    
    for(xml_node<> *nextwafer = wafer->next_sibling(); nextwafer; nextwafer = nextwafer->next_sibling())
    {
        int marks_this_wafer = 0;
        for(xml_node<> * measurement = nextwafer->first_node("MeasurementList")->first_node("Measurement"); measurement; measurement = measurement->next_sibling())
        {
            dx[index] = atof(measurement->first_node("OverlayMeasurement")->first_node("Overlay")->first_node("X")->value());
            dy[index] = atof(measurement->first_node("OverlayMeasurement")->first_node("Overlay")->first_node("Y")->value());
            validx[index] = (strcmp(measurement->first_node("OverlayMeasurement")->first_node("Valid")->first_node("X")->value(), "true") == 0);
            validy[index] = (strcmp(measurement->first_node("OverlayMeasurement")->first_node("Valid")->first_node("Y")->value(), "true") == 0);
            index++;
            marks_this_wafer++;
        }
        if (marks_this_wafer != mark_count)
        {    
            printf("ERROR: inconsistent wafer definitions in ADELmetrology file\n");
            exit(0);
        }
    }

    doc.clear();
    
}