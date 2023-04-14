base='\\asml.com\eu\shared\nl011002\wwwovl\www\data';
data_num=2;
file{1}='\m3322\service_data\XY\XYDSU_20131023_m3322_20131023_1058\XYDSU_m3322_20131023_1058.tlg';
file{2}='\m5786\service_data\XY\XYDSU_20160903_m5786_20160903_1618\XYDSU_m5786_20160903_1618.tlg';
close all

data=[base file{data_num}];
mli=ovl_read_testlog(data, 'info');
dummy =  ovl_create_dummy(mli,'marklayout','BA-XY-DYNA-13X19');
ml_in_13x19=ovl_interp_layout(mli, dummy);
ml_in_13x19.info = mli.info;
ml_in_13x19.expinfo = mli.expinfo;
 ml_in=ovl_model(ml_in_13x19, '10par');
ml_field_chk1 = ovl_average_fields(ml_in);
[par_mc, extra_data, par, KPI, RES]=BMMO_model_inlineSDM(ml_field_chk1, ml_field_chk1);

corr_inlineSDM= ovl_add(extra_data.corr.scan(1), extra_data.corr.lens);

[res, par] =ovl_model(ml_field_chk1,'18par');
corr_18par = ovl_sub(ml_field_chk1, res);

% openppt('new')
newslide('')
figure; ovl_plot(ml_field_chk1,'pcolor','scale',0,'prc',2,'title','Input-10par/6par removed on 13x19','field','fontsize',14);
figppt(1,[3,5,6],'bitmap');
figure; ovl_plot(extra_data.input.lens,'pcolor','scale',0,'prc',2,'title','Lens model input','field','fontsize',14);
figppt(2,[2,5,2],'bitmap');
figure; ovl_plot(extra_data.input.scan(1),'pcolor','scale',0,'prc',2,'title','HOC  model input','field','fontsize',14);
figppt(3,[2,5,7],'bitmap');
figure; ovl_plot(extra_data.corr.lens,'pcolor','scale',0,'prc',2,'title','Lens model Corr','field','fontsize',14);
figppt(4,[4,5,3],'bitmap');
figure; ovl_plot(ovl_sub(extra_data.input.lens, extra_data.corr.lens),'pcolor','scale',0,'prc',2,'title','Lens model res','field','fontsize',14);
figppt(5,[4,5,8],'bitmap');
figure; ovl_plot(extra_data.corr.scan(1),'pcolor','scale',0,'prc',2,'title','HOC model Corr','field','fontsize',14);
figppt(6,[4,5,13],'bitmap');
figure; ovl_plot(ovl_sub(extra_data.input.scan(1), extra_data.corr.scan(1)),'pcolor','scale',0,'prc',2,'title','HOC model res','field','fontsize',14);
figppt(7,[4,5,18],'bitmap');
figure; ovl_plot(corr_inlineSDM,'pcolor','scale',0,'prc',2,'title','Corr(Lens+scan)-inline SDM','field','fontsize',14);
figppt(8,[4,5,4],'bitmap');
figure; ovl_plot(corr_18par,'pcolor','scale',0,'prc',2,'title','18par K factors','field','fontsize',14);
figppt(9,[4,5,9],'bitmap');
figure; ovl_plot(ovl_sub(ml_field_chk1, corr_inlineSDM),'pcolor','scale',0,'prc',2, 'title','NCE - inline SDM','field','fontsize',14);
figppt(10,[4,5,14],'bitmap');
figure; ovl_plot(res,'pcolor','scale',0,'prc',2,'title','NCE -18par K factors model','field','fontsize',14);
figppt(11,[4,5,19],'bitmap');
figure; ovl_plot(ovl_sub(corr_inlineSDM, corr_18par),'pcolor','scale',0,'prc',2, 'title','Corr Delta','field','fontsize',14);
figppt(12,[3,5,5],'bitmap');
close all