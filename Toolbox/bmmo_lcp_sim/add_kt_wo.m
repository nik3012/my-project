
function add_kt_wo(kt_wo_in, kt_wo_offset, kt_wo_template)
% function add_kt_wo(kt_wo_in, kt_wo_offset, kt_wo_template)
%
% Add KT_wafers_out offset file kt_wo_offset to kt_wo_in, given
% kt_wo_template as the nominal mark positions of the offsets in
% kt_wo_offset, saving the result locally in the file KT_wo_delta
%
% Input  
%   kt_wo_in: KT_wafers_out file
%   kt_wo_offset: KT_wafers_out file containing offsets from nominal
%       positions only
%   kt_wo_template: KT_wafers_out file containing nominal positions of all
%       marks in kt_wo_offset
%
%  2016???? SBPR Creation


disp('loading KT wafers out files');
kt_in = dd2mat(0, kt_wo_in);
kt_template = dd2mat(0, kt_wo_template);
kt_offset = dd2mat(0, kt_wo_offset);

markname = {'BMMO'    'BMMO_WID'    'EXPOSED!'};
marktype = {'FM_2'    'NVSM-X'    'XPA'};

THRESH = 1e-6;

temp_pos = [kt_template.AA_marks.position];

offset_pos = [kt_offset.AA_marks.position];

for in = 1:3
    for jn = 1:3
        disp(['matching [' markname{in} ',' marktype{jn} '] marks']);
        
        index_in = strcmp({kt_in(1).AA_marks.name}, markname{in}) & strcmp({kt_in(1).AA_marks.mark_type}, marktype{jn});
        index_temp = strcmp({kt_template.AA_marks.name}, markname{in}) & strcmp({kt_template.AA_marks.mark_type}, marktype{jn});
        
        temp_xy = [[temp_pos(index_temp).x]' [temp_pos(index_temp).y]'];
        offset_xy = [[offset_pos(index_temp).x]' [offset_pos(index_temp).y]'];
        
        linear_ids = find(index_in);
        
        if length(linear_ids) > 0    
            for iw = 1:length(kt_in)

                kt_pos = [kt_in(iw).AA_marks.position];
                kt_xy = [[kt_pos(index_in).x]' [kt_pos(index_in).y]'];

                % find the nearest match in temp_xy for each kt_xy
                [I, D] = knnsearch(temp_xy, kt_xy);

                kt_xy = kt_xy + offset_xy(I, :);


                for id = 1:length(linear_ids)
                    if D(id) < THRESH
                        kt_in(iw).AA_marks(linear_ids(id)).position.x = kt_xy(id, 1);
                        kt_in(iw).AA_marks(linear_ids(id)).position.y = kt_xy(id, 2);
                    end
                end
            end
        end
    end
end

mat2dd('KT_wo_delta', kt_in);