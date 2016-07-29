********************************************************************************
*
* Program to make figures for 2016 Stata Conference Talk
*
* Mary Kay Trimner & Dale Rhoda
* 
* Biostat Global Consulting
*
* Dale.Rhoda@biostatglobal.com
*
********************************************************************************
cd "Q:\BGC - Stata Conference 2016\Figures\"

graph drop _all

excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_01.xlsx"
excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_02.xlsx"
excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_03.xlsx"
excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_04.xlsx"
excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_05.xlsx"
excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_06.xlsx"
excel_wrapper_for_iwplot_svyp "stata_conference_harmonia_07.xlsx"
excel_wrapper_for_iwplot_svyp "N_nineteen.xlsx"
graph drop _all

