function add_kt_wo_simple(kt_wo_in, kt_wo_offset)
% function add_kt_wo_simple(kt_wo_in, kt_wo_offset)
%
% Add two KT wafers out files, mark-to-mark, saving the output to
% KT_wo_delta_simple in the current directory
%
% Input:
%   kt_wo_in, kt_wo_offset: KT_wafers_out_files
%
% 2016???? SBPR Creation

disp('loading KT wafers out files');
kt_in = dd2mat(0, kt_wo_in);
kt_offset = dd2mat(0, kt_wo_offset);


for iw = 1:length(kt_in)
    for im = 1:length(kt_in(iw).AA_marks)
        kt_in(iw).AA_marks(im).position.x = kt_in(iw).AA_marks(im).position.x + kt_offset(iw).AA_marks(im).position.x;
        kt_in(iw).AA_marks(im).position.y = kt_in(iw).AA_marks(im).position.y + kt_offset(iw).AA_marks(im).position.y;
    end
end


mat2dd('KT_wo_delta_simple', kt_in);