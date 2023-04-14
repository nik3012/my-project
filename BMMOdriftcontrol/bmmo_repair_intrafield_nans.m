function mlo = bmmo_repair_intrafield_nans(mli, options)
% function mlo = bmmo_repair_intrafield_nans(mli, options)
%
% This function removes NaNs in the input by applying the 20par/33par model.
% The modeling type is configured through options.INTRAF.
% 
% Input:
%  mli: input ml structure
%  options: BMMO/BL3 option structure with field: INTRAF.name
%
% Output: 
%  mlo: output ml structure with Nans repaired if there exists

mlo = mli;
parNames = options.INTRAF.name;
parNames = {'tx', 'ty', parNames{:}};

for iwaf = 1:mli.nwafer
    for ilayer = 1:mli.nlayer
        
        ind_nan = isnan(mli.layer(ilayer).wr(iwaf).dx) | isnan(mli.layer(ilayer).wr(iwaf).dy);
        
        if ~isempty(ind_nan)
            mli_tmp = ovl_get_wafers(ovl_get_layers(mli, ilayer), iwaf);
            [res, parlist] = ovl_model(mli_tmp, parNames, 'perfield');
            parlist = bmmo_add_field_positions_to_parlist(parlist, mli_tmp);
            ml_par = ovl_model(ovl_create_dummy(mli_tmp), 'apply', parlist);

            mlo.layer(ilayer).wr(iwaf).dx(ind_nan) = ml_par.layer.wr.dx(ind_nan);
            mlo.layer(ilayer).wr(iwaf).dy(ind_nan) = ml_par.layer.wr.dy(ind_nan);
        end
    end
end
