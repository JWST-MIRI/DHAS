pro make_saveset
.compile run_ql_vm.pro
.compile run_dhas_vm.pro
resolve_all
save,/routines,filename='run_ql_vm.sav'
end
exit
