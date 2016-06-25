:: ----flp.bat------

:: This is the batch file for flp project. Inputs:
:: 'usa_00016' imports and labels IPUMS file. [on L drive: L:\Research\Resurgence\IPUMS]
:: 'dual_career_update' runs IPUMS analysis on probability of living in central city (stock and flow)
:: 'gwg_conflict' estimates GWG by city-year (completed: standard mincer, progress: Oaxaca, lasso)
:: 'gwg_gent_alz' does a number of things, uses various crosswalks by MSA over time, look into further!


statase -b usa_00016.do
statase -b dual_career_update.do
statase -b gwg_conflict.do
statase -b gwg_gent_alz.do



	