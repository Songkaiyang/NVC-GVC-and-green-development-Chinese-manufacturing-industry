*=======设定主面板数据集，包括三个维度、解释变量和中介变量
import excel "C:\Users\lenovo\Desktop\主面板数据集.xls", sheet("主面板数据集") firstrow clear
save "C:\Users\lenovo\Desktop\主面板数据集.dta"


*=======设置被解释变量数据集（样本量1581）
import excel "C:\Users\lenovo\Desktop\A157 全国绿色发展指数和子指数（2011-2019）.xlsx", sheet("Sheet0") firstrow clear
rename 总指标绿色化指数 green
rename 经济增长绿化度指数 ecogreen
rename 资源环境承载潜力指数 resgreen
rename 政府政策支持度指数 polgreen
rename 年份 year
rename 地区 id

drop in 271/275
drop G H I 

destring year, replace

save "C:\Users\lenovo\Desktop\被解释变量数据集.dta"


*=======合并数据集（样本量1530）
*被解释变量
use "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta" 
merge m:1 id year using "C:\Users\lenovo\Desktop\被解释变量数据集.dta",keep(3) nogen
save "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta", replace

*控制变量：water atmosphere fixed
clear
import excel "C:\Users\lenovo\Desktop\中国环境统计年鉴-地区版2.0.xlsx", sheet("ARIMA填补(慎用)") firstrow clear
save "C:\Users\lenovo\Desktop\控制变量water atmosphere fixed.dta"

use "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta" 
merge m:1 id year using "C:\Users\lenovo\Desktop\控制变量water atmosphere fixed.dta",keep(3) nogen
save "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta", replace

*控制变量：indwater
import excel "C:\Users\lenovo\Desktop\工业用水总量-宋改1.xlsx", sheet("原始数据") firstrow clear
save "C:\Users\lenovo\Desktop\控制变量 indwater.dta", replace

use "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta" 
merge m:1 id year using "C:\Users\lenovo\Desktop\控制变量 indwater.dta",keep(3) nogen
save "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta", replace

*=======合并老数据集中的其它变量(样本量 1479)
order labor, before(economic1)

drop 省份 
drop T C D NVC_Pat_f GVC_Pat_f 
drop green ecogreen resgreen polgreen _est_z6 greenindex_w ecogreenindex_w resourgreenindex_w policygreenindex_w lag_ecogreenindex 
drop water atmosphere fixed 
drop indwater 
drop T_w C_w D_w labor_w envir_w water_w atmosphere_w fixed_w Isu_w indwater_w energy_w lag_year lag_T lag_C lag_D lag2_T lag2_C lag2_D lag2_year 
order labor, before(economic1)
drop 行政区划代码 地区等级 地区 长江经济带 
drop I

use "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta" 
merge 1:1 id year ind using "C:\Users\lenovo\Desktop\Panel data(3）20260414（疑似未正确匹配）.dta",keep(3) nogen
save "C:\Users\lenovo\Desktop\SKY Panel data 20260419.dta", replace




*=============实证部分
cd C:\Users\lenovo\Desktop //我的电脑路径


********描述性统计
logout, save(描述性统计) word replace: tabstat green ecogreen resgreen polgreen D T C water atmosphere fixed indwater NVC_Pat_f GVC_Pat_f envir Isu, stat(N mean sd min max) c(s) f(%6.2f)


***相关性分析
logout, save(相关性分析) word replace: pwcorr_a green ecogreen resgreen polgreen D T C water atmosphere fixed indwater NVC_Pat_f GVC_Pat_f envir Isu


***多重共线性检查
reg green D water atmosphere fixed indwater NVC_Pat_f GVC_Pat_f envir Isu
vif
reg ecogreen D water atmosphere fixed indwater NVC_Pat_f GVC_Pat_f envir Isu
vif
reg resgreen D water atmosphere fixed indwater NVC_Pat_f GVC_Pat_f envir Isu
vif
reg polgreen D water atmosphere fixed indwater NVC_Pat_f GVC_Pat_f envir Isu
vif


****基准回归
reghdfe green D water atmosphere fixed indwater, absorb(ind year ind#year)
est store z1
reghdfe ecogreen D water atmosphere fixed indwater, absorb(ind year ind#year)
est store z2
reghdfe resgreen D water atmosphere fixed indwater, absorb(ind year ind#year)
est store z3
reghdfe polgreen D water atmosphere fixed indwater, absorb(ind year ind#year)
est store z4
outreg2 [z1 z2 z3 z4] using 基准回归（4控制）.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes")replace


******稳健性检验
***（1）替换解释变量（协调指数T）
reghdfe green T water atmosphere fixed indwater, absorb(ind year ind#year)
est store z1
reghdfe ecogreen T water atmosphere fixed indwater, absorb(ind year ind#year)
est store z2
reghdfe resgreen T water atmosphere fixed indwater, absorb(ind year ind#year)
est store z3
reghdfe polgreen T water atmosphere fixed indwater, absorb(ind year ind#year)
est store z4
outreg2 [z1 z2 z3 z4] using 稳健性检验-替换解释变量（协调指数T）.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes")replace

***（2）替换解释变量（耦合度C）
reghdfe green C water atmosphere fixed indwater, absorb(ind year ind#year)
est store z1
reghdfe ecogreen C water atmosphere fixed indwater, absorb(ind year ind#year)
est store z2
reghdfe resgreen C water atmosphere fixed indwater, absorb(ind year ind#year)
est store z3
reghdfe polgreen C water atmosphere fixed indwater, absorb(ind year ind#year)
est store z4
outreg2 [z1 z2 z3 z4] using 稳健性检验-替换解释变量（耦合度C）.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes")replace


***（3）缩尾
ssc install winsor2, replace
winsor2 D water atmosphere fixed indwater,cut(1 99)
winsor2 green ecogreen resgreen polgreen,cut(1 99)

*新出现的变量：D_w water_w atmosphere_w fixed_w indwater_w green_w ecogreen_w resgreen_w polgreen_w

reghdfe green_w D_w water_w atmosphere_w fixed_w indwater_w, absorb(ind year ind#year)
est store z1
reghdfe ecogreen_w D_w water_w atmosphere_w fixed_w indwater_w, absorb(ind year ind#year)
est store z2
reghdfe resgreen_w D_w water_w atmosphere_w fixed_w indwater_w, absorb(ind year ind#year)
est store z3
reghdfe polgreen_w D_w water_w atmosphere_w fixed_w indwater_w, absorb(ind year ind#year)
est store z4
outreg2 [z1 z2 z3 z4] using 稳健性检验-缩尾.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes")replace

save "C:\Users\lenovo\Desktop\SKY Panel data 20260505.dta", replace


***（4）改变耦合协调度模型的α和β系数
*合并数据集（样本量1479）
import excel "C:\Users\lenovo\Desktop\重算DTC（改α和β）.xls", sheet("补充稳健性检验αβ改") firstrow clear
save "C:\Users\lenovo\Desktop\补充稳健性检验αβ改.dta"

use "C:\Users\lenovo\Desktop\SKY Panel data 20260505.dta" 
merge 1:1 id year ind using "C:\Users\lenovo\Desktop\补充稳健性检验αβ改.dta",keep(3) nogen
save "C:\Users\lenovo\Desktop\SKY Panel data 20260505（改）.dta", replace

***（4）（1）α07_β03
reghdfe green D_α07_β03 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z1
reghdfe ecogreen D_α07_β03 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z2
reghdfe resgreen D_α07_β03 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z3
reghdfe polgreen D_α07_β03 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z4
outreg2 [z1 z2 z3 z4] using 新基准回归（α07_β03）.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes")replace

***（4）（2）α03_β07
reghdfe green D_α03_β07 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z1
reghdfe ecogreen D_α03_β07 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z2
reghdfe resgreen D_α03_β07 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z3
reghdfe polgreen D_α03_β07 water atmosphere fixed indwater, absorb(ind year ind#year)
est store z4
outreg2 [z1 z2 z3 z4] using 新基准回归（α03_β07）.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes")replace


***（5）补充一个稳健性检验：控制省份
reghdfe green D water atmosphere fixed indwater, absorb(ind year ind#year id)
est store z1
reghdfe ecogreen D water atmosphere fixed indwater, absorb(ind year ind#year id)
est store z2
reghdfe resgreen D water atmosphere fixed indwater, absorb(ind year ind#year id)
est store z3
reghdfe polgreen D water atmosphere fixed indwater, absorb(ind year ind#year id)
est store z4
outreg2 [z1 z2 z3 z4] using 稳健性检验-增加控制省份.doc, tstat bdec(3) tdec(2) addtext("Ind","Yes","Year","Yes","Ind#Year","Yes","Id","Yes")replace


******内生性检验，IV2个：Topo Academy
***被解释变量green
*========================================================
* 2SLS：第一阶段（t统计量）+ 第二阶段（z统计量）
*========================================================
* Step 1: 第一阶段（手动OLS）
reg D Topo Academy water atmosphere fixed indwater, robust
est store first_ols
* Step 2: 第二阶段2SLS
ivregress 2sls green (D = Topo Academy)  water atmosphere fixed indwater, robust first
est store second_2sls
* Step 3: 输出到RTF
esttab first_ols second_2sls  using "2SLS_results(green,Topo+Academy,robust).rtf",  replace label b(3) z(3) star(* 0.1 ** 0.05 *** 0.01)  title("2SLS回归结果：被解释变量 green") mtitles("第一阶段（D）" "第二阶段（green）")   note("***p<0.01, **p<0.05, *p<0.1, t statistics in parentheses within first stage, z statistics in parentheses within second stage.")
***弱相关性检验，通过
ivregress 2sls green (D= Topo Academy) water atmosphere fixed indwater, robust
estat firststage
***内生性检验，通过
estat endog
***过度识别检验(使用异方差稳健标准误，不聚类)，通过
ivregress 2sls green (D= Topo Academy ) water atmosphere fixed indwater, robust
estat overid


***被解释变量ecogreen
*========================================================
* 2SLS：第一阶段（t统计量）+ 第二阶段（z统计量）
*========================================================
* Step 1: 第一阶段（手动OLS）
reg D Topo Academy water atmosphere fixed indwater, robust
est store first_ols
* Step 2: 第二阶段2SLS
ivregress 2sls ecogreen (D = Topo Academy)  water atmosphere fixed indwater, robust first
est store second_2sls
* Step 3: 输出到RTF
esttab first_ols second_2sls  using "2SLS_results(ecogreen,Topo+Academy,robust).rtf",  replace label b(3) z(3) star(* 0.1 ** 0.05 *** 0.01)  title("2SLS回归结果：被解释变量 ecogreen") mtitles("第一阶段（D）" "第二阶段（ecogreen）")   note("***p<0.01, **p<0.05, *p<0.1, t statistics in parentheses within first stage, z statistics in parentheses within second stage.")
***弱相关性检验，通过
ivregress 2sls ecogreen (D= Topo Academy) water atmosphere fixed indwater, robust
estat firststage
***内生性检验，通过
estat endog
***过度识别检验(使用异方差稳健标准误，不聚类)，通过
ivregress 2sls ecogreen (D= Topo Academy) water atmosphere fixed indwater, robust
estat overid


***被解释变量resgreen
*========================================================
* 2SLS：第一阶段（t统计量）+ 第二阶段（z统计量）
*========================================================
* Step 1: 第一阶段（手动OLS）
reg D Topo Academy water atmosphere fixed indwater, robust
est store first_ols
* Step 2: 第二阶段2SLS
ivregress 2sls resgreen (D = Topo Academy)  water atmosphere fixed indwater, robust first
est store second_2sls
* Step 3: 输出到RTF
esttab first_ols second_2sls  using "2SLS_results(resgreen,Topo+Academy,robust).rtf",  replace label b(3) z(3) star(* 0.1 ** 0.05 *** 0.01)  title("2SLS回归结果：被解释变量 resgreen") mtitles("第一阶段（D）" "第二阶段（resgreen）")   note("***p<0.01, **p<0.05, *p<0.1, t statistics in parentheses within first stage, z statistics in parentheses within second stage.")
***弱相关性检验，通过
ivregress 2sls resgreen (D= Topo Academy) water atmosphere fixed indwater, robust
estat firststage
***内生性检验，通过
estat endog
***过度识别检验(使用异方差稳健标准误，不聚类)，通过
ivregress 2sls resgreen (D= Topo Academy) water atmosphere fixed indwater, robust
estat overid


***被解释变量polgreen
*========================================================
* 2SLS：第一阶段（t统计量）+ 第二阶段（z统计量）
*========================================================
* Step 1: 第一阶段（手动OLS）
reg D Topo Academy water atmosphere fixed indwater, robust
est store first_ols
* Step 2: 第二阶段2SLS
ivregress 2sls polgreen (D = Topo Academy)  water atmosphere fixed indwater, robust first
est store second_2sls
* Step 3: 输出到RTF
esttab first_ols second_2sls  using "2SLS_results(polgreen,Topo+Academy,robust).rtf",  replace label b(3) z(3) star(* 0.1 ** 0.05 *** 0.01)  title("2SLS回归结果：被解释变量 polgreen") mtitles("第一阶段（D）" "第二阶段（polgreen）")   note("***p<0.01, **p<0.05, *p<0.1, t statistics in parentheses within first stage, z statistics in parentheses within second stage.")
***弱相关性检验，通过
ivregress 2sls polgreen (D= Topo Academy) water atmosphere fixed indwater, robust
estat firststage
***内生性检验，通过
estat endog
***过度识别检验(使用异方差稳健标准误，不聚类)，通过
ivregress 2sls polgreen (D= Topo Academy) water atmosphere fixed indwater, robust
estat overid


******机制检验：中介效应，4个中介变量
******中介变量(1)envir
***中介效应检验（Bootstrap法）
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation green, mv(envir) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation ecogreen, mv(envir) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation resgreen, mv(envir) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation polgreen, mv(envir) iv(D) cv(water atmosphere fixed indwater) 


******中介变量(2)Isu
***中介效应检验（Bootstrap法）
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation green, mv(Isu) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation ecogreen, mv(Isu) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation resgreen, mv(Isu) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation polgreen, mv(Isu) iv(D) cv(water atmosphere fixed indwater) 


******中介变量(3)NVC_Pat_f
***中介效应检验（Bootstrap法）
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation green, mv(NVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation ecogreen, mv(NVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation resgreen, mv(NVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation polgreen, mv(NVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 


******中介变量(4)GVC_Pat_f
***中介效应检验（Bootstrap法）
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation green, mv(GVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation ecogreen, mv(GVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation resgreen, mv(GVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation polgreen, mv(GVC_Pat_f) iv(D) cv(water atmosphere fixed indwater) 


save "C:\Users\lenovo\Desktop\SKY Panel data", replace