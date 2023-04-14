#include "mex.h"
#include "rapidxml/rapidxml.hpp"
#include "rapidxml/rapidxml_print.hpp"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>
#include <stdio.h>
#include <string.h>

using namespace std;
using namespace rapidxml;

const char *root_attribs[] = {
    "xmlns:ADELmetrology",
    "xmlns:ext",
    "xmlns:metro",
};

const char *root_urls[] = {
    "http://www.asml.com/XMLSchema/MT/YieldStar/ADELmetrology/v2.4",
    "http://www.asml.com/Extension/MT/YieldStar/Queries",
    "http://www.asml.com/XMLSchema/MT/YieldStar/ADELmetrology/v2.4",
};

// index of preallocated element names
enum {
    RESULTS,
    WAFERRESULTLIST,
    WAFERRESULT,
    LOADPORT,
    CARRIERID,
    SLOTID,
    STATUS,
    //OVERLAYCOARSEDETECTED,
    WAFERID,
    MEASUREMENTLIST,
    MEASUREMENT,
    SEQUENCENUMBER,
    MEASUREMENTNUMBER,
    TYPE,
    RECIPETARGETID,
    TARGETLABEL,
    TARGETTOMEASUREID,
    TARGETROTATION,
    SAMPLESCHEMENAME,
    GRIDINFO,
    NAME,
    LOCATION,
    ROW,
    COL,
    MEASUREMENTOPTION,
    MEASUREMENTSTARTTIME,
    FIELDPOSITION,
    X,
    Y,
    TARGETPOSITION,
    MEASUREMENTPROFILENAME,
    MEASUREMENTPROFILEID,
    //DOSEFACTOR,
    OVERLAYMEASUREMENT,
    OVERLAY,
    SIG,
    VALID,
    PROCESSCOMPLETE,
    UNIT,
    MM,
    NM,
    V_ZERO,
    V_ONE,
    UNKNOWN,
    GRID,
    V_TRUE,
    V_FALSE,
    STANDARD,
    OV,
    D_ZERO,
    DEG,
};

const char *default_value[] = {
    "",
    "",
    "",
    "1",
    "unknown",
    "",
    "Processed",
    "false",
};

const char *element_name[] = {
    "Results",
    "WaferResultList",
    "WaferResult",
    "LoadPort",
    "CarrierId",
    "SlotId",
    "Status",
    //"OverlayCoarseDetected",
    "WaferId",
    "MeasurementList",
    "Measurement",
    "SequenceNumber",
    "MeasurementNumber",
    "Type",
    "RecipeTargetId",
    "TargetLabel",
    "TargetToMeasureId",
    "TargetRotation",
    "SampleSchemeName",
    "GridInfo",
    "Name",
    "Location",
    "Row",
    "Col",
    "MeasurementOption",
    "MeasurementStartTime",
    "FieldPosition",
    "X",
    "Y",
    "TargetPosition",
    "MeasurementProfileName",
    "MeasurementProfileId",
    //"DoseFactor",
    "OverlayMeasurement",
    "Overlay",
    "Sig",
    "Valid",
    "ProcessComplete",
    "unit",
    "mm",
    "nm",
    "0",
    "1",
    "unknown",
    "grid",
    "true",
    "false",
    "Standard",
    "OV",
    "0.0",
    "deg",
};

xml_node<> *allocate_rootnode(xml_document<> *doc)
{
    
 char *root_name = doc->allocate_string("ADELmetrology:MetrologyReport", 0);   
 xml_node<> *node = doc->allocate_node(node_element, root_name);
 for(int i = 0; i < 3; i++)
 {
     xml_attribute<> *attr = doc->allocate_attribute(root_attribs[i], root_urls[i]);
     node->append_attribute(attr);
 }
 
 return node;
}

int get_num_wafers(const mxArray *mlPtr)
{
   const mxArray *fPtr;
   int rval = 0; 
   
   fPtr = mxGetField(mlPtr, 0, "nwafer");
   if(fPtr != NULL) {
       double *pr; 
       pr = mxGetPr(fPtr);
       rval = (int)(pr[0]);
   }        
   return rval;
}

xml_document<> *allocate_wr_generic_data(xml_node<> *wr_node, xml_document<> *doc, int wafer)
{
    char *buf;
    int w_str_len = 2;
    
    buf = doc->allocate_string(0, w_str_len);
    sprintf(buf, "%d", wafer + 1);
    
    wr_node->append_node(doc->allocate_node(node_element, element_name[LOADPORT], default_value[LOADPORT]));
    wr_node->append_node(doc->allocate_node(node_element, element_name[CARRIERID], default_value[CARRIERID]));
    wr_node->append_node(doc->allocate_node(node_element, element_name[SLOTID], buf));
    wr_node->append_node(doc->allocate_node(node_element, element_name[STATUS], default_value[STATUS]));
    //wr_node->append_node(doc->allocate_node(node_element, element_name[OVERLAYCOARSEDETECTED], default_value[OVERLAYCOARSEDETECTED]));
    wr_node->append_node(doc->allocate_node(node_element, element_name[WAFERID], buf));

    return doc;
}

int get_total_measurements(const mxArray *mlPtr, int im)
{
  const mxArray *p;
  int curr_total = 0;

  p = mxGetField(mlPtr, im, "wd");
  p = mxGetField(p, 0, "xc");
  curr_total += (int)mxGetM(p);
  
  return curr_total;
}

xml_node<> *allocate_overlay_node(const double *dx, const double *dy, const mxLogical *xv, const mxLogical *yv, xml_document<> *doc, const int it)
{
 xml_node<> *overlay_node, *subnode, *xnode, *ynode;   
 overlay_node = doc->allocate_node(node_element, element_name[OVERLAYMEASUREMENT]);
 char *xval, *yval;
 const char *xvalid, *yvalid;
 int buflen = 12;
 double dxval = 0.0;
 double dyval = 0.0;
 
 xval = doc->allocate_string(0, buflen);
 yval = doc->allocate_string(0, buflen);
 
 // only print valid values
 if (xv[it])
     dxval = dx[it];
 
 if (yv[it])
     dyval = dy[it];
 
 sprintf(xval, "%.3lf", dxval);
 sprintf(yval, "%.3lf", dyval);
 
 // x and y overlay values
 subnode = doc->allocate_node(node_element, element_name[OVERLAY]);
 xnode = doc->allocate_node(node_element, element_name[X], xval);
 xnode->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[NM]));
 ynode = doc->allocate_node(node_element, element_name[Y], yval);
 ynode->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[NM]));
 subnode->append_node(xnode);
 subnode->append_node(ynode);
 overlay_node->append_node(subnode);
 
 // sig values
 subnode = doc->allocate_node(node_element, element_name[SIG]);
 xnode = doc->allocate_node(node_element, element_name[X], element_name[D_ZERO] );
 xnode->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[NM]));
 ynode = doc->allocate_node(node_element, element_name[Y], element_name[D_ZERO] );
 ynode->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[NM]));
 subnode->append_node(xnode);
 subnode->append_node(ynode);
 overlay_node->append_node(subnode);
 
 // valid values
 subnode = doc->allocate_node(node_element, element_name[VALID]);
 if (xv[it])
     xvalid = element_name[V_TRUE];
 else
     xvalid = element_name[V_FALSE];
 
 if (yv[it])
     yvalid = element_name[V_TRUE];
 else
     yvalid = element_name[V_FALSE];
 
 subnode->append_node(doc->allocate_node(node_element, element_name[X], xvalid));
 subnode->append_node(doc->allocate_node(node_element, element_name[Y], yvalid));
 overlay_node->append_node(subnode);
 
 return overlay_node;
}

xml_node<> *allocate_field_node(const double *xc, const double *yc, xml_document<> *doc, const int it, const char *name)
{
  xml_node<> *field_node, *xnode, *ynode;
  
  char *xval, *yval;
  int buflen = 12;
  
  xval = doc->allocate_string(0, buflen);
  yval = doc->allocate_string(0, buflen);
  sprintf(xval, "%.4lf", xc[it]);
  sprintf(yval, "%.4lf", yc[it]);
  
  field_node = doc->allocate_node(node_element, name);
  xnode = doc->allocate_node(node_element, element_name[X], xval);
  xnode->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[MM]));
  ynode = doc->allocate_node(node_element, element_name[Y], yval);
  ynode->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[MM]));
  field_node->append_node(xnode);
  field_node->append_node(ynode);
          
  return field_node;  
}

xml_node<> *allocate_meas_grid_node(const double *gridrow, const double *gridcol, xml_document<> *doc, const int it)
{
    xml_node<> *grid_node, *loc_node;
    char *rowval;
    char *colval;
    int buflen = 16;
    
    
    //getindex(mli.wd.yc(j,1)*1e3,cellsize_y,grid_offset_y)
    rowval = doc->allocate_string( 0, buflen);
    colval = doc->allocate_string( 0, buflen);
    sprintf(rowval, "%d", (int)gridrow[it]);
    sprintf(colval, "%d", (int)gridcol[it]);
    
    grid_node = doc->allocate_node(node_element, element_name[GRIDINFO]);
    grid_node->append_node(doc->allocate_node(node_element, element_name[NAME], element_name[GRID]));
    loc_node = doc->allocate_node(node_element, element_name[LOCATION]);
    
    loc_node->append_node(doc->allocate_node(node_element, element_name[ROW], rowval));
    loc_node->append_node(doc->allocate_node(node_element, element_name[COL], colval));
    
    grid_node->append_node(loc_node);
    
    return grid_node;
}

xml_document<> *allocate_measurement_data(const mxArray *mlPtr, xml_document<> *doc, xml_node<> *m_node, int wafer)
{
  mwSize num_ml;         // number of elements in struct array
  mwIndex index;                    
  int number_of_fields, field_index;
  const char  *field_name;
  const mxArray *field_array_ptr;
  const mxArray *string_array_ptr;

  const double *grow, *gcol, *xc, *yc, *xf, *yf, *dx, *dy;
  const mxLogical *xv, *yv;
  xml_node<> *meas_node, *rcp_node, *grid_node, *tgt_node, *fld_node, *ovl_node;
  char *meas_value;
  char *meas_time;
  char *label_value;     
  int buflen = 12;
  int nwafer;
  int total_meas = 0;
      
 /* get the number of ml structures */     
 num_ml = mxGetNumberOfElements(mlPtr);
 for(int im = 0; im < num_ml; im++) {     
 
    /* get the number of measurements */
    total_meas = get_total_measurements(mlPtr, im);
    
    /* get the target and overlay data */
    field_array_ptr = mxGetField(mlPtr, im, "wd");
    xc = mxGetPr(mxGetField(field_array_ptr, 0, "xc"));
    yc = mxGetPr(mxGetField(field_array_ptr, 0, "yc"));
    xf = mxGetPr(mxGetField(field_array_ptr, 0, "xf"));
    yf = mxGetPr(mxGetField(field_array_ptr, 0, "yf"));
    
    field_array_ptr = mxGetField(mxGetField(mlPtr, im, "layer"), 0, "wr");
    dx = mxGetPr(mxGetField(field_array_ptr, wafer, "dx"));
    dy = mxGetPr(mxGetField(field_array_ptr, wafer, "dy"));
    xv = (mxLogical *)mxGetData(mxGetField(field_array_ptr, wafer, "xv"));
    yv = (mxLogical *)mxGetData(mxGetField(field_array_ptr, wafer, "yv"));
    
    /* get the grid data */
    field_array_ptr = mxGetField(mxGetField(mlPtr, im, "info"), 0, "griddata");
    grow = mxGetPr(mxGetField(field_array_ptr, 0, "row"));
    gcol = mxGetPr(mxGetField(field_array_ptr, 0, "col"));
    
    
    /* get the target label */
    //mexPrintf("reading target label\n");
    label_value = doc->allocate_string(0, buflen);
    field_array_ptr = mxGetField(mlPtr, im, "info");
    string_array_ptr = mxGetField(field_array_ptr, 0, "targetLabel");
    if (mxGetString(string_array_ptr, label_value, buflen) != 0)
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray",
            "Could not convert string data.");
                
    /* get the measurement time */
    //mexPrintf("reading measure time\n");
    meas_time = doc->allocate_string(0, 24);
    field_array_ptr = mxGetField(mlPtr, im, "info");
    string_array_ptr = mxGetField(field_array_ptr, 0, "measTime");
    if (mxGetString(string_array_ptr, meas_time, 24) != 0)
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray",
            "Could not convert string data.");           
   
    for(int it = 0; it < total_meas; it++) {
        
        /* generic data */
        meas_node = doc->allocate_node(node_element, element_name[MEASUREMENT]);
        meas_value = doc->allocate_string(0, buflen);
        sprintf(meas_value, "%d", it+1);
        meas_node->append_node(doc->allocate_node(node_element, element_name[SEQUENCENUMBER], meas_value));
        meas_node->append_node(doc->allocate_node(node_element, element_name[MEASUREMENTNUMBER], meas_value));
        meas_node->append_node(doc->allocate_node(node_element, element_name[TYPE], element_name[OV]));
        rcp_node = doc->allocate_node(node_element, element_name[RECIPETARGETID]);
        rcp_node->append_node(doc->allocate_node(node_element, element_name[TARGETLABEL], label_value));
        rcp_node->append_node(doc->allocate_node(node_element, element_name[TARGETTOMEASUREID], element_name[UNKNOWN]));

        meas_node->append_node(rcp_node);
        rcp_node = doc->allocate_node(node_element, element_name[TARGETROTATION], element_name[D_ZERO]);
        rcp_node->append_attribute(doc->allocate_attribute(element_name[UNIT], element_name[DEG]));
        meas_node->append_node(rcp_node);
        meas_node->append_node(doc->allocate_node(node_element, element_name[SAMPLESCHEMENAME], element_name[UNKNOWN]));

        /* grid data */
        meas_node->append_node(allocate_meas_grid_node(grow, gcol, doc, it)); 
        
        /* more generic data */
        meas_node->append_node(doc->allocate_node(node_element, element_name[MEASUREMENTOPTION], element_name[STANDARD]));
        meas_node->append_node(doc->allocate_node(node_element, element_name[MEASUREMENTSTARTTIME], meas_time));

        /* field data */
        meas_node->append_node(allocate_field_node(xc, yc, doc, it, element_name[FIELDPOSITION]));
                
        /* target data */
        meas_node->append_node(allocate_field_node(xf, yf, doc, it, element_name[TARGETPOSITION]));
        
        /* last generic data */
        meas_node->append_node(doc->allocate_node(node_element, element_name[MEASUREMENTPROFILENAME], element_name[UNKNOWN]));
        meas_node->append_node(doc->allocate_node(node_element, element_name[MEASUREMENTPROFILEID], element_name[UNKNOWN]));
        //meas_node->append_node(doc->allocate_node(node_element, element_name[DOSEFACTOR], element_name[V_ZERO]));

        /* overlay data */
        meas_node->append_node(allocate_overlay_node(dx, dy, xv, yv, doc, it));
        
        m_node->append_node(meas_node);
    }
 }
 return doc;   
}

xml_document<> *allocate_result_node(const mxArray *mlPtr, xml_document<> *doc, xml_node<> *root)
{
      xml_node<> *results_node, *wrl_node, *wr_node, *m_node, *status_node;
      char *value;
      int buflen;
      int nwafer;

      results_node = doc->allocate_node(node_element, element_name[RESULTS]);
      root->append_node(results_node);
      wrl_node = doc->allocate_node(node_element, element_name[WAFERRESULTLIST]);
      results_node->append_node(wrl_node);
      
      nwafer = get_num_wafers(mlPtr);
      /* wafer results per wafer */
      for(int iwafer = 0; iwafer < nwafer; iwafer++){
          wr_node = doc->allocate_node(node_element, element_name[WAFERRESULT]);
          wrl_node->append_node(wr_node);
          doc = allocate_wr_generic_data(wr_node, doc, iwafer);
          m_node = doc->allocate_node(node_element, element_name[MEASUREMENTLIST]);
          wr_node->append_node(m_node);
          doc = allocate_measurement_data(mlPtr, doc, m_node, iwafer); 
      }
      status_node = doc->allocate_node(node_element, element_name[STATUS], element_name[PROCESSCOMPLETE]);
      results_node->append_node(status_node);
      return doc;
}



xml_document<> *allocate_info_nodes(const mxArray *sPtr, xml_document<> *doc, xml_node<> *root)
{
      mwSize total_num_of_elements;         // number of elements in struct array
      mwIndex index;                    
      int number_of_fields, field_index;
      const char  *field_name;
      const mxArray *field_array_ptr;
      mxClassID  category;
      xml_node<> *newnode;
      char *value;
      int buflen;
      
      total_num_of_elements = mxGetNumberOfElements(sPtr); 
      number_of_fields = mxGetNumberOfFields(sPtr);

      /* go through each element in the struct array */
      for (index=0; index<total_num_of_elements; index++)  {
        /* For the given index, walk through each field. */ 
        for (field_index=0; field_index<number_of_fields; field_index++)  {
            
         field_name = mxGetFieldNameByNumber(sPtr, field_index);
         
         //mexPrintf("Processing field %s\n", field_name);
         
         field_array_ptr = mxGetFieldByNumber(sPtr, index, field_index);
         if (field_array_ptr == NULL) {
            //mexPrintf("\tEmpty Field\n");
         } 
         else  {
            category = mxGetClassID(field_array_ptr);
            switch(category) {
                case mxSTRUCT_CLASS:   
                 
                    newnode = doc->allocate_node(node_element, field_name);
                    root->append_node(newnode);
                    doc = allocate_info_nodes(field_array_ptr, doc, newnode); 

                    break;
            
                case mxCHAR_CLASS:
                     // unfortunately we have to copy the value
                     buflen = mxGetNumberOfElements(field_array_ptr) + 1;
                     value = doc->allocate_string(0, buflen);
                     if (mxGetString(field_array_ptr, value, buflen) != 0) {
                        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray",
                            "Could not convert string data.");
                     }
                     if(strcmp(field_name, "unit") == 0) {     
                         // this is an attribute
                         root->append_attribute(doc->allocate_attribute(field_name, value));
                     } else if (strcmp(field_name, "val") == 0) {
                         root->value(value);
                     } else {             
                         newnode = doc->allocate_node(node_element, field_name, value);
                         root->append_node(newnode);
                     }
                     break;
                
                default: mexPrintf("Unknown field category\n"); break;
                        
            }
         }
        }
      //mexPrintf("\n\n");
  }
    

   return doc; 
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    //mexPrintf(">mexFunction\n");

    xml_document<> doc;
    char *meas_time;
    char filename[100];
    
    if (mxGetString(prhs[2], filename, 100) != 0) {
                        mexPrintf("Cannot input parse filename: using test.xml");
                        sprintf(filename, "test.xml");
                     }
    
    
    //mexPrintf("allocating root node\n");
    
    xml_node<> *rootnode = allocate_rootnode(&doc);
    
    //mexPrintf("appending root node \n");
    
    doc.append_node(rootnode);
    
    //mexPrintf("appending info nodes \n");
    allocate_info_nodes(prhs[0], &doc, rootnode);
    
    //mexPrintf("appending result node \n");
    allocate_result_node(prhs[1], &doc, rootnode);
    
    //mexPrintf("output to file\n");
    
    ofstream myfile;
    myfile.open(filename);
    myfile << "<?xml version=\"1.0\" encoding=\"utf-8\"?>" << endl;
    myfile << doc;
    myfile.close();
    
    doc.clear();
    
    //mexPrintf("<mexFunction\n");
}

