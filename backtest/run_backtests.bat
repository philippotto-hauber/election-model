cd ..
@REM  2005: CC winner
quarto render ./backtest/prepare_polls.qmd -P year=2005
cd backtest
rename prepare_polls.html prepare_polls_2005.html
cd ..
Rscript --vanilla ./backtest/backtest_models.r 2005
quarto render ./backtest/plot_backtest_results.qmd -P year=2005 
cd backtest
rename plot_backtest_results.html plot_backtest_results_2005.html
cd ..

@REM  2019: DGM winner
quarto render ./backtest/prepare_polls.qmd -P year=2019
cd backtest
rename prepare_polls.html prepare_polls_2019.html
cd ..
Rscript --vanilla ./backtest/backtest_models.r 2019
quarto render ./backtest/plot_backtest_results.qmd -P year=2019
cd backtest
rename plot_backtest_results.html plot_backtest_results_2019.html
cd ..

@REM  2023: PDAL winner
quarto render ./backtest/prepare_polls.qmd -P year=2023
cd backtest
rename prepare_polls.html prepare_polls_2023.html
cd ..
Rscript --vanilla ./backtest/backtest_models.r 2023
quarto render ./backtest/plot_backtest_results.qmd -P year=2023
cd backtest
rename plot_backtest_results.html plot_backtest_results_2023.html
cd ..

