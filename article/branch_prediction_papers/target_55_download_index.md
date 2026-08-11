# Branch Prediction Target 55 Download Index

本索引对应 2026-08-11 整理的 55 篇分支预测文献清单。去重时同时核对题名、作者、出版场合、版本和 SHA-256；同一技术的不同正式出版版本不强行合并。

当前结果：

- 52 项已有与目标题名相符的公开全文 PDF；
- 第 2 项的 1984 IEEE Computer 正式版未开放，保存同作者 1983 年 Berkeley 44 页技术报告；
- 第 48 项的 ISCA 2026 正式版未开放，保存第一作者公开学位论文作为明确标注的代理材料；
- 第 47 项 ISCA 2026 RUNLTS 正式版为 closed，当前没有公开全文，未用 2025 年版本冒充；
- 本目录另保留 5 份清单外补充材料；全部 59 份本地 PDF 的文件哈希互不重复。

## 1–15：经典动态预测、Path 与 Aliasing

| 编号 | 文献 | 本地文件 | 下载来源与状态 |
|---:|---|---|---|
| 1 | Smith, *A Study of Branch Prediction Strategies* (1981) | [PDF](classic/01_1981_smith_study_branch_prediction_strategies.pdf) | [公开扫描版](https://ctho.org/toread/finished/smith2.pdf)，已下载 |
| 2 | Lee & Smith, *Branch Prediction Strategies and Branch Target Buffer Design* (1984) | [1983 Berkeley 技术报告](classic/02_1983_lee_smith_analysis_branch_prediction_btb_design.pdf) | [Berkeley 官方机构版](https://www2.eecs.berkeley.edu/Pubs/TechRpts/1983/6335.html)；1984 期刊正式版 closed，当前文件是同作者长版替代材料 |
| 3 | Yeh & Patt, *Two-Level Adaptive Training Branch Prediction* (1991) | [PDF](classic/03_1991_yeh_patt_two_level_adaptive_training.pdf) | [UC Davis 课程镜像](https://american.cs.ucdavis.edu/academic/readings/papers/yeh91twolevel.pdf)，已下载 |
| 4 | Yeh & Patt, *Alternative Implementations of Two-Level Adaptive Branch Prediction* (1992) | [PDF](classic/04_1992_yeh_patt_alternative_two_level_implementations.pdf) | [Berkeley 课程镜像](https://people.eecs.berkeley.edu/~kubitron/courses/cs252-F03/handouts/papers/p451-yeh.pdf)，已下载 |
| 5 | Pan, So & Rahmeh, *Improving the Accuracy of Dynamic Branch Prediction Using Branch Correlation* (1992) | [PDF](classic/1992_pan_so_rahmeh_branch_correlation.pdf) | [University of Amsterdam](https://staff.fnwi.uva.nl/s.polstra/psa2017/p76-pan.pdf)，已下载 |
| 6 | McFarling, *Combining Branch Predictors* (1993) | [PDF](classic/05_1993_mcfarling_combining_branch_predictors.pdf) | [UC Davis 课程镜像](https://american.cs.ucdavis.edu/academic/readings/papers/mcfarling.pdf)，已下载 |
| 7 | Yeh & Patt, *A Comparison of Dynamic Branch Predictors that Use Two Levels of Branch History* (1993) | [PDF](classic/1993_yeh_patt_comparison_two_level_branch_predictors.pdf) | [Harvard](https://www.eecs.harvard.edu/cs146-246/p257-yeh.pdf)，已下载 |
| 8 | Nair, *Dynamic Path-Based Branch Correlation* (1995) | [PDF](classic/1995_nair_dynamic_path_based_branch_correlation.pdf) | [ACM 原始发布 PDF 的公开存档](https://web.archive.org/web/20001001205511id_/http://www.acm.org:80/pubs/articles/proceedings/micro/225160/p15-nair/p15-nair.pdf)，已下载 |
| 9 | Sechrest, Lee & Mudge, *Correlation and Aliasing in Dynamic Branch Predictors* (1996) | [PDF](classic/06_1996_sechrest_lee_mudge_correlation_aliasing.pdf) | [作者机构页](https://tnm.engin.umich.edu/wp-content/uploads/sites/353/2017/12/1996.05.Correlation-and-aliasing-in-dynamic-branch-predictors.pdf)，已下载 |
| 10 | Sprangle et al., *The Agree Predictor* (1997) | [PDF](classic/07_1997_sprangle_et_al_agree_predictor.pdf) | [Georgia Tech](https://bpb-us-e1.wpmucdn.com/sites.gatech.edu/dist/8/175/files/2015/08/AgreePredictor.pdf?bid=175)，已下载 |
| 11 | Lee, Chen & Mudge, *The Bi-Mode Branch Predictor* (1997) | [PDF](classic/08_1997_lee_chen_mudge_bi_mode_predictor.pdf) | [Berkeley 课程镜像](https://people.eecs.berkeley.edu/~kubitron/courses/cs152-S04/handouts/papers/p4-lee.pdf)，已下载 |
| 12 | Michaud, Seznec & Uhlig, *Trading Conflict and Capacity Aliasing in Conditional Branch Predictors* (1997) | [PDF](classic/1997_michaud_seznec_uhlig_conflict_capacity_aliasing.pdf) | [公开原文扫描镜像](https://ctho.org/toread/finished/p292-michaud.pdf)，已下载；作者旧链已失效 |
| 13 | Eden & Mudge, *The YAGS Branch Prediction Scheme* (1998) | [PDF](classic/09_1998_eden_mudge_yags.pdf) | [UC Davis 课程镜像](https://american.cs.ucdavis.edu/academic/readings/papers/yags.pdf)，已下载 |
| 14 | Evers et al., *An Analysis of Correlation and Predictability* (1998) | [PDF](classic/10_1998_evers_et_al_correlation_predictability.pdf) | [Berkeley 课程镜像](https://people.eecs.berkeley.edu/~kubitron/cs252/handouts/papers/p52-evers.pdf)，已下载 |
| 15 | Kessler, *The Alpha 21264 Microprocessor* (1999) | [PDF](classic/1999_kessler_alpha_21264_microprocessor.pdf) | [TAMU 教学镜像](https://people.engr.tamu.edu/djimenez/taco/utsa-www/cs5513-fall07/reader/kessler-alpha.pdf)，已下载 |

## 16–30：延迟、Neural、O-GEHL 与 TAGE

| 编号 | 文献 | 本地文件 | 下载来源与状态 |
|---:|---|---|---|
| 16 | Jiménez, Keckler & Lin, *The Impact of Delay on the Design of Branch Predictors* (2000) | [PDF](classic/11_2000_jimenez_keckler_lin_impact_of_delay.pdf) | [University of Utah](https://users.cs.utah.edu/~rajeev/cs7810/papers/jimenez00.pdf)，已下载 |
| 17 | Jiménez & Lin, *Dynamic Branch Prediction with Perceptrons* (2001) | [PDF](classic/12_2001_jimenez_lin_perceptron.pdf) | [作者页](https://www.cs.utexas.edu/~lin/papers/hpca01.pdf)，已下载 |
| 18 | Jiménez & Lin, *Neural Methods for Dynamic Branch Prediction* (2002) | [PDF](neural/2002_jimenez_lin_neural_methods_dynamic_branch_prediction.pdf) | [UT Austin 作者页](https://www.cs.utexas.edu/~lin/papers/tocs02.pdf)，已下载 |
| 19 | Seznec et al., *Design Tradeoffs for the Alpha EV8 Conditional Branch Predictor* (2002) | [PDF](classic/2002_seznec_felix_krishnan_sazeides_alpha_ev8.pdf) | [University of Cyprus](https://www5.cs.ucy.ac.cy/carch/xi/papers/Design_Tradeoffs.pdf)，已下载 |
| 20 | Jiménez, *Fast Path-Based Neural Branch Prediction* (2003) | [PDF](neural/2003_jimenez_fast_path_based_neural_branch_prediction.pdf) | [TAMU 作者页](https://people.engr.tamu.edu/djimenez/taco/pdfs/micro03_dist.pdf)，已下载 |
| 21 | Jiménez, *Piecewise Linear Branch Prediction* (2005) | [PDF](neural/2005_jimenez_piecewise_linear_branch_prediction.pdf) | [TAMU 作者页](https://people.engr.tamu.edu/djimenez/taco/pdfs/isca05_dist.pdf)，已下载 |
| 22 | Seznec, *Analysis of the O-GEometric History Length Branch Predictor* (2005) | [PDF](tage/13_2005_seznec_o_gehl.pdf) | [ISCA 2005](https://pages.cs.wisc.edu/~isca2005/papers/06B-03.PDF)，已下载 |
| 23 | Seznec & Michaud, *A Case for (Partially) Tagged Geometric History Length Branch Prediction* (2006) | [PDF](tage/14_2006_seznec_michaud_original_tage.pdf) | [JILP](https://jilp.org/vol8/v8paper1.pdf)，已下载 |
| 24 | Seznec, *The L-TAGE Branch Predictor* (2007) | [PDF](tage/24_2007_seznec_l_tage.pdf) | [JILP](https://www.jilp.org/vol9/v9paper6.pdf)，已下载 |
| 25 | Seznec, *A New Case for the TAGE Branch Predictor* (2011) | [PDF](tage/15_2011_seznec_new_case_for_tage.pdf) | [CMU 课程镜像](https://www.cs.cmu.edu/~18742/papers/Seznec2011.pdf)，已下载 |
| 26 | Seznec, *A 64-Kbytes ITTAGE Indirect Branch Predictor* (2011) | [PDF](tage/26_2011_seznec_64_kbytes_ittage.pdf) | [JWAC-2 / JILP](https://jilp.org/jwac-2/program/cbp3_07_seznec.pdf)，已下载 |
| 27 | Seznec, *TAGE-SC-L Branch Predictors* (2014) | [PDF](tage/16a_2014_seznec_tage_sc_l.pdf) | [CBP 2014](https://jilp.org/cbp2014/paper/AndreSeznec.pdf)，已下载 |
| 28 | Seznec, San Miguel & Albericio, *The Inner Most Loop Iteration Counter* (2015) | [PDF](tage/28_2015_seznec_et_al_imli.pdf) | [Iowa State 课程镜像](https://class.ece.iastate.edu/tyagi/cpre581/papers/Micro15InnerMostLoop.pdf)，已下载 |
| 29 | Seznec, *TAGE-SC-L Branch Predictors Again* (2016) | [PDF](tage/16b_2016_seznec_tage_sc_l_again.pdf) | [CBP 2016](https://www.jilp.org/cbp2016/paper/AndreSeznecLimited.pdf)，已下载 |
| 30 | Jiménez, *Multiperspective Perceptron Predictor* (2016) | [PDF](modern/30_2016_jimenez_multiperspective_perceptron.pdf) | [CBP 2016](https://www.jilp.org/cbp2016/paper/DanielJimenez1.pdf)，已下载；与目录中的 2025 版本不同 |

## 31–39：综述、H2P、Value 与层级化预测

| 编号 | 文献 | 本地文件 | 下载来源与状态 |
|---:|---|---|---|
| 31 | Mittal, *A Survey of Techniques for Dynamic Branch Prediction* (2018/2019) | [PDF](modern/31_2018_mittal_dynamic_branch_prediction_survey.pdf) | [arXiv](https://arxiv.org/pdf/1804.00261)，已下载 |
| 32 | Lin & Tarsa, *Branch Prediction Is Not a Solved Problem* (2019) | [PDF](modern/17_2019_lin_tarsa_branch_prediction_not_solved.pdf) | [arXiv](https://arxiv.org/pdf/1906.08170)，已下载 |
| 33 | Tarsa et al., *Improving Branch Prediction by Modeling Global History with Convolutional Neural Networks* (2019) | [PDF](modern/33_2019_tarsa_et_al_cnn_global_history.pdf) | [arXiv](https://arxiv.org/pdf/1906.09889)，已下载 |
| 34 | Zangeneh et al., *BranchNet* (2020) | [PDF](modern/34_2020_zangeneh_et_al_branchnet.pdf) | [UT Austin HPS](https://hps.ece.utexas.edu/pub/BranchNet_Micro2020.pdf)，已下载 |
| 35 | Sridhar, Kabylkas & Renau, *Load Driven Branch Predictor (LDBP)* (2020) | [PDF](modern/35_2020_sridhar_et_al_ldbp.pdf) | [arXiv](https://arxiv.org/pdf/2009.09064)，已下载 |
| 36 | Pruett & Patt, *Branch Runahead* (2021) | [PDF](modern/36_2021_pruett_patt_branch_runahead.pdf) | [UT Austin HPS](https://utw10235.utweb.utexas.edu/pub/PruettPatt_BranchRunahead.pdf)，已下载 |
| 37 | Zouzias et al., *Identifying and Exploiting Sparse Branch Correlations* (2022) | [PDF](modern/37_2022_zouzias_et_al_sparse_branch_correlations.pdf) | [arXiv](https://arxiv.org/pdf/2207.14033)，已下载 |
| 38 | Khan et al., *Whisper* (2022) | [PDF](modern/38_2022_khan_et_al_whisper.pdf) | [作者页](https://takhandipu.github.io/papers/khan-whisper-micro-2022.pdf)，已下载 |
| 39 | Schall, Sandberg & Grot, *The Last-Level Branch Predictor* (2024) | [PDF](modern/39_2024_schall_et_al_last_level_branch_predictor.pdf) | [Edinburgh Research Explorer](https://www.pure.ed.ac.uk/ws/portalfiles/portal/479516450/SchallEtalMICRO2024TheLast-LevelBranchPredictor.pdf)，已下载；含 1 页仓储封面 |

## 40–48：CBP 2025 与 ISCA 2026

| 编号 | 文献 | 本地文件 | 下载来源与状态 |
|---:|---|---|---|
| 40 | Seznec, *TAGE-SC for CBP2025* | [PDF](cbp2025/01_seznec_tage_sc_for_cbp2025.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final37-Seznec.pdf)，已下载 |
| 41 | Ros, *A Deep Dive Into TAGE-SC-L* | [PDF](cbp2025/02_ros_deep_dive_tage_sc_l.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final2-Ros.pdf)，已下载 |
| 42 | Koizumi et al., *RUNLTS: Register-value-aware Predictor Utilizing Nested Large Tables* | [PDF](cbp2025/03_koizumi_et_al_runlts.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final44-Koizumi.pdf)，已下载；不是第 47 项正式版 |
| 43 | Man et al., *LVCP* | [PDF](cbp2025/04_man_et_al_lvcp.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final15-Man.pdf)，已下载 |
| 44 | Mose et al., *PIP: An Ensemble of Programming-Idiom Predictors* | [PDF](cbp2025/05_mose_et_al_pip.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final19-Mose.pdf)，已下载 |
| 45 | Behrendt et al., *Taming Wild Branches: ... Bullseye Predictor* | [PDF](cbp2025/08_behrendt_et_al_bullseye.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final36-Behrendt.pdf)，已下载 |
| 46 | Fan, *Branch Prediction via Load Value Prediction: A Case of BALL* | [PDF](cbp2025/09_fan_ball_predictor.pdf) | [CBP 2025](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final56-Fan.pdf)，已下载 |
| 47 | Koizumi et al., *RUNLTS: Branch Prediction with Register-Value Correlations and Hierarchical Table Orchestration* (ISCA 2026) | 无公开 PDF | [DOI](https://doi.org/10.1109/ISCA66397.2026.00051)；OpenAlex 标记 closed，无 OA 仓储全文。正式版 16 页，未用第 42 项冒充 |
| 48 | Singh, Li & Rotenberg, *Augmenting the Branch Predictor with a Squashed-Branch Reuse Buffer* (ISCA 2026) | [公开学位论文代理](isca2026/48_singh_2026_dissertation_squashed_branch_reuse_proxy.pdf) | 正式稿 [DOI](https://doi.org/10.1109/ISCA66397.2026.00052) 为 closed；[NCSU 公开学位论文](https://repository.lib.ncsu.edu/server/api/core/bitstreams/c564dc41-e6d4-4bce-bdb6-b639d19cc68a/content) 的作者声明明确指出第 1.3、3、4 章对应这项研究，但代理不是 15 页正式稿 |

## 49–53：CBP-NG 2026

| 编号 | 文献 | 本地文件 | 下载来源与状态 |
|---:|---|---|---|
| 49 | Dang & Rotenberg, *An Energy-Efficient Ahead-Pipelined TAGE Branch Predictor for CBP-NG* | [PDF](cbp_ng_2026/01_dang_rotenberg_ahead_pipelined_tage.pdf) | [CBP-NG Proceedings](https://archive.org/download/cbp-ng_proceedings/Dang_Rotenberg-paper.pdf)，已下载 |
| 50 | Gupta et al., *RABT: Run-Ahead Block TAGE* | [PDF](cbp_ng_2026/04_gupta_et_al_rabt.pdf) | [CBP-NG Proceedings](https://archive.org/download/cbp-ng_proceedings/Gupta_et_al-paper.pdf)，已下载 |
| 51 | Koizumi et al., *MORSL* | [PDF](cbp_ng_2026/05_koizumi_et_al_morsl.pdf) | [CBP-NG Proceedings](https://archive.org/download/cbp-ng_proceedings/Koizumi_et_al-paper.pdf)，已下载 |
| 52 | Sethumadhavan, *Distilled Branch Predictors* | [PDF](cbp_ng_2026/03_sethumadhavan_distilled_branch_predictors.pdf) | [CBP-NG Proceedings](https://archive.org/download/cbp-ng_proceedings/Sethumadhavan-paper.pdf)，已下载 |
| 53 | Balivada & Susarla, *Offset-Free TAGE-SC* | [PDF](cbp_ng_2026/07_balivada_susarla_offset_free_tage_sc.pdf) | [CBP-NG Proceedings](https://archive.org/download/cbp-ng_proceedings/Balivada_Susarla-paper.pdf)，已下载 |

## 54–55：Target Prediction 支线

| 编号 | 文献 | 本地文件 | 下载来源与状态 |
|---:|---|---|---|
| 54 | Kaeli & Emma, *Branch History Table Prediction of Moving Target Branches Due to Subroutine Returns* (1991) | [PDF](classic/1991_kaeli_emma_moving_target_returns.pdf) | [ACM 原始发布 PDF 的公开存档](https://web.archive.org/web/20000930114220id_/http://www.acm.org:80/pubs/articles/proceedings/isca/115952/p34-kaeli/p34-kaeli.pdf)，已下载 |
| 55 | Chang, Hao & Patt, *Target Prediction for Indirect Jumps* (1997) | [PDF](classic/1997_chang_hao_patt_target_prediction_indirect_jumps.pdf) | [CMU 公开课程镜像存档](https://web.archive.org/web/20240413162715id_/https://course.ece.cmu.edu/~ece447/s15/lib/exe/fetch.php?media=p274-chang.pdf)，已下载 |

## 清单外补充材料

以下 5 份文件原先已经存在，内容有价值但不占用目标 55 的编号：

1. [TAGE-SC-L with a Code Structure Correlator](cbp2025/06_cai_et_al_code_structure_correlator.pdf)
2. [Multiperspective Perceptron Predictor — CBP 2025 version](cbp2025/07_jimenez_multiperspective_perceptron.pdf)
3. [A Scoring Metric for the CBP-NG Championship](cbp_ng_2026/00_michaud_vfs_scoring_metric.pdf)
4. [Enhance Ahead-Pipelined N-Branch GShare with Tagged Tables](cbp_ng_2026/02_fan_ahead_pipelined_n_branch_gshare.pdf)
5. [Coding Agents as Design Searchers](cbp_ng_2026/06_pallan_coding_agents_tage_tuning.pdf)

## 本地验证

- 本地 PDF：59 份，共 776 页；
- 所有文件均具有 PDF 文件头，并通过 `pdfinfo` 解析；
- 所有文件的 SHA-256 均唯一，没有重复下载的相同文件；
- 除扫描版 Lee–Smith 技术报告外，其余文件前两页均可直接提取正文文本；该扫描报告此前已经逐页渲染核查；
- 第 42 项 CBP 2025 RUNLTS 与第 47 项 ISCA 2026 RUNLTS 是不同题名、不同会场、不同页数的独立出版版本，不按重复项处理。
