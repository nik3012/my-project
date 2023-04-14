Option_access_permission = 1; % 0 for no permission
if Option_access_permission  
    base='\\asml.com\eu\shared\nl011002\wwwovl\www\data';
    file{1}='\m3322\service_data\XY\XYDSU_20131023_m3322_20131023_1058\XYDSU_m3322_20131023_1058.tlg';
    file{2}='\m6269\service_data\XY\XYDSU_20130316_m6269_20130316_1745\XYDSU_m6269_20130316_1745.tlg';
    file{3}='\m5061\service_data\XY\XYDSU_20140111_m5061_20141011_2423\XYDSU_m5061_20141011_2423.tlg';
    file{4}='\m4129\service_data\XY\XYDSU_20140829_m4129_20140829_1035\XYDSU_m4129_20140829_1035.tlg';
    file{5}='\m3680\service_data\XY\XYDSU_20140417_m3680_20140417_0932\XYDSU_m3680_20140417_0932.tlg';
    file{6}='\m6817\service_data\XY\XYDSU_20141124_m6817_20141124_1247\XYDSU_m6817_20141124_1247.tlg';
    file{7}='\m4092\service_data\XY\XYDSU_20140626_m4092_20140626_2200\XYDSU_m4092_20140626_2200.tlg';
    file{8}='\m6269\service_data\XY\XYDSU_20140428_m6269_20140428_1627\XYDSU_m6269_20140428_1627.tlg';
    file{9}='\m3322\service_data\XY\XYDSU_20141018_m3322_20141018\XYDSU_m3322_20141018.tlg';
    file{10}='\m6817\service_data\XY\XYDSU_20141123_m6817_20141123_1840\XYDSU_m6817_20141123_1840.tlg';

else
    base='\\asml.com\eu\shared\nl011052\BMMO_NXE_TS\01-Functional\102-Study_items\BMMO_inlineSDM\data_temp';
    file{1}='\XYDSU_m3322_20131023_1058.tlg';
    file{2}='\XYDSU_m6269_20130316_1745.tlg';
    file{3}='\XYDSU_m5061_20141011_2423.tlg';
    file{4}='\XYDSU_m4129_20140829_1035.tlg';
    file{5}='\XYDSU_m3680_20140417_0932.tlg';
    file{6}='\XYDSU_m6817_20141124_1247.tlg';
    file{7}='\XYDSU_m4092_20140626_2200.tlg';
    file{8}='\XYDSU_m6269_20140428_1627.tlg';
    file{9}='\XYDSU_m3322_20141018.tlg';
    file{10}='\XYDSU_m6817_20141123_1840.tlg';
end


% [ratio,pres]=openppt('Impact on szd.pptx','new');
vec_z2_before=[];
vec_z3_before=[];
vec_z4plus_before=[];
vec_z2_after=[];
vec_z3_after=[];
vec_z4plus_after=[];
% for i=1:2:size(file,2)
for i=1:size(file,2)
    close all

%     for j=1:2
       j=1;
        data=[base file{i+(j-1)}];
        mli=ovl_read_testlog(data, 'info');
        
        dummy =  ovl_create_dummy(mli,'marklayout','BA-XY-DYNA-13X19');
        ml_in_13x19=ovl_interp_layout(mli, dummy);
        ml_in_13x19.info = mli.info;
        ml_in_13x19.expinfo = mli.expinfo;
        %% Removing 10 pars - Shall be done on LCP
        ml_in=ovl_model(ml_in_13x19, '10par'); 
%        if j==1
            ml_field_chk1 = ovl_average_fields(ml_in); 
%        elseif j==2
            ml_field_chk2 = ovl_combine_linear(ovl_average_fields(ml_in), 0); 
%        end
%   end
    
    [par_mc, extra_data, par, KPI, RES]=BMMO_model_inlineSDM(ml_field_chk1, ml_field_chk1);
%     vec_z2_before=[vec_z2_before par.m_before(:,:,2)];
%     vec_z3_before=[vec_z3_before par.m_before(:,:,3)];
%     vec_z4plus_before=[vec_z4plus_before max(par.m_before(:,:,4:end))];
%     vec_z2_after=[vec_z2_after par.m_after(:,:,2)];
%     vec_z3_after=[vec_z3_after par.m_after(:,:,3)];
%     vec_z4plus_after=[vec_z4plus_after max(par.m_after(:,:,4:end))];
    
%     clearvars -except par_mc extra_data par KPI RES ml_field_chk1 ml_field_chk2 base file
%     figure; ovl_plot(ml_field_chk1,'pcolor','scale',0,'prc',3,'field','Input for inline-SDM')
%     figure; ovl_plot(extra_data.input.lens,'pcolor','scale',0,'prc',3,'field','Lens input')
%     figure; ovl_plot(extra_data.corr.lens,'pcolor','scale',0,'prc',3,'field','Lens correction')
%     figure; ovl_plot(extra_data.input.scan(1),'pcolor','scale',0,'prc',3,'field','HOC input')
%     figure; ovl_plot(extra_data.corr.scan(1),'pcolor','scale',0,'prc',3,'field','HOC correction')
%     figure; ovl_plot(ovl_sub(ml_field_chk1, ovl_add(extra_data.corr.lens(1), extra_data.corr.scan(1))),'pcolor','scale',0,'prc',3,'field','Residue')
%   
%     
%     newslide();%set(i,'Position',[180,300,1000,700])
%     figppt(1,[2,5,1],'bitmap');
%     figppt(2,[2,5,2],'bitmap');
%     figppt(3,[2,5,3],'bitmap');
%     figppt(4,[2,5,7],'bitmap');
%     figppt(5,[2,5,8],'bitmap');
%     figppt(6,[2,5,10],'bitmap');
%     figppt(101,[4,5,4],'bitmap');
%     figppt(102,[4,5,9],'bitmap');
%     figppt(100,[4,5,5],'bitmap');
%     figppt(103,[4,5,10],'bitmap');

end
%  saveppt;
%  closeppt;

% figure; plot(vec_z2_before,'.-'); hold on; plot(vec_z2_after,'r+-'); legend('before LM','after LM','Location','best'); title('Z2')
% figure; plot(vec_z3_before,'.-'); hold on; plot(vec_z3_after,'r+-'); legend('before LM','after LM','Location','best'); title('Z3')
% figure; plot(vec_z4plus_before,'.-'); hold on; plot(vec_z4plus_after,'r+-'); legend('before LM','after LM','Location','best'); title('Z4+')
