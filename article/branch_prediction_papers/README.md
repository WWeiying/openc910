# Branch Prediction Papers

本目录收录分支预测发展主线论文，以及 CBP2025、CBP-NG 2026 的公开论文集。文件均在 2026-08-10 下载，并已检查为可解析的 PDF；共 35 份。

中文教学资料：[Branch Prediction Papers Chinese Guide](branch_prediction_papers_chinese_guide.md)。该文档按 35 份 PDF 逐篇、依原文章节顺序展开，每篇独立保留问题设定、机制、公式、参数、实验、图表数据、结论、教学解析与技术演进位置。重要图表均以中文说明标题、坐标、数据和体系结构含义，不直接嵌入 PDF 页面或页面截图。

## Foundations

1. [A Study of Branch Prediction Strategies](classic/01_1981_smith_study_branch_prediction_strategies.pdf) — James E. Smith, ISCA 1981. [PDF source](https://ctho.org/toread/finished/smith2.pdf)
2. [Analysis of Branch Prediction Strategies and Branch Target Buffer Design](classic/02_1983_lee_smith_analysis_branch_prediction_btb_design.pdf) — Johnny K. F. Lee and Alan Jay Smith, UC Berkeley Technical Report UCB/CSD-83-121, 1983. [Official record and PDF](https://www2.eecs.berkeley.edu/Pubs/TechRpts/1983/6335.html)
3. [Two-Level Adaptive Training Branch Prediction](classic/03_1991_yeh_patt_two_level_adaptive_training.pdf) — Tse-Yu Yeh and Yale N. Patt, MICRO 1991. [PDF source](https://american.cs.ucdavis.edu/academic/readings/papers/yeh91twolevel.pdf)
4. [Alternative Implementations of Two-Level Adaptive Branch Prediction](classic/04_1992_yeh_patt_alternative_two_level_implementations.pdf) — Tse-Yu Yeh and Yale N. Patt, ISCA 1992. [PDF source](https://people.eecs.berkeley.edu/~kubitron/courses/cs252-F03/handouts/papers/p451-yeh.pdf)
5. [Combining Branch Predictors](classic/05_1993_mcfarling_combining_branch_predictors.pdf) — Scott McFarling, WRL Technical Note TN-36, 1993. [PDF source](https://american.cs.ucdavis.edu/academic/readings/papers/mcfarling.pdf)
6. [Correlation and Aliasing in Dynamic Branch Predictors](classic/06_1996_sechrest_lee_mudge_correlation_aliasing.pdf) — Stuart Sechrest, Chih-Chieh Lee, and Trevor Mudge, ISCA 1996. [Author-hosted PDF](https://tnm.engin.umich.edu/wp-content/uploads/sites/353/2017/12/1996.05.Correlation-and-aliasing-in-dynamic-branch-predictors.pdf)
7. [The Agree Predictor: A Mechanism for Reducing Negative Branch History Interference](classic/07_1997_sprangle_et_al_agree_predictor.pdf) — Eric Sprangle, Robert S. Chappell, Mitch Alsup, and Yale N. Patt, ISCA 1997. [PDF source](https://bpb-us-e1.wpmucdn.com/sites.gatech.edu/dist/8/175/files/2015/08/AgreePredictor.pdf?bid=175)
8. [The Bi-Mode Branch Predictor](classic/08_1997_lee_chen_mudge_bi_mode_predictor.pdf) — Chih-Chieh Lee, I-Cheng K. Chen, and Trevor Mudge, MICRO 1997. [PDF source](https://people.eecs.berkeley.edu/~kubitron/courses/cs152-S04/handouts/papers/p4-lee.pdf)
9. [The YAGS Branch Prediction Scheme](classic/09_1998_eden_mudge_yags.pdf) — A. N. Eden and Trevor Mudge, MICRO 1998. [PDF source](https://american.cs.ucdavis.edu/academic/readings/papers/yags.pdf)
10. [An Analysis of Correlation and Predictability: What Makes Two-Level Branch Predictors Work](classic/10_1998_evers_et_al_correlation_predictability.pdf) — Marius Evers, Sanjay J. Patel, Robert S. Chappell, and Yale N. Patt, ISCA 1998. [PDF source](https://people.eecs.berkeley.edu/~kubitron/cs252/handouts/papers/p52-evers.pdf)
11. [The Impact of Delay on the Design of Branch Predictors](classic/11_2000_jimenez_keckler_lin_impact_of_delay.pdf) — Daniel A. Jiménez, Stephen W. Keckler, and Calvin Lin, MICRO 2000. [PDF source](https://users.cs.utah.edu/~rajeev/cs7810/papers/jimenez00.pdf)
12. [Dynamic Branch Prediction with Perceptrons](classic/12_2001_jimenez_lin_perceptron.pdf) — Daniel A. Jiménez and Calvin Lin, HPCA 2001. [Author-hosted PDF](https://www.cs.utexas.edu/~lin/papers/hpca01.pdf)

### Note on Lee and Smith (1984)

The requested IEEE Computer article is *Branch Prediction Strategies and Branch Target Buffer Design*, 17(1):6–22, 1984, DOI `10.1109/MC.1984.1658927`. Its exact publisher PDF is not openly downloadable. The local file is the openly available, 44-page UC Berkeley technical report by the same authors from 1983. It is a closely related institutional version, but its title and pagination differ from the 1984 journal article; it is intentionally labeled as the technical report rather than as the journal PDF.

## O-GEHL, TAGE, and TAGE-SC-L

13. [Analysis of the O-GEometric History Length Branch Predictor](tage/13_2005_seznec_o_gehl.pdf) — André Seznec, ISCA 2005. [Official conference PDF](https://pages.cs.wisc.edu/~isca2005/papers/06B-03.PDF)
14. [A Case for (Partially) TAgged GEometric History Length Branch Prediction](tage/14_2006_seznec_michaud_original_tage.pdf) — André Seznec and Pierre Michaud, JILP 2006. [Official JILP PDF](https://jilp.org/vol8/v8paper1.pdf)
15. [A New Case for the TAGE Branch Predictor](tage/15_2011_seznec_new_case_for_tage.pdf) — André Seznec, MICRO 2011. [PDF source](https://www.cs.cmu.edu/~18742/papers/Seznec2011.pdf)
16a. [TAGE-SC-L Branch Predictors](tage/16a_2014_seznec_tage_sc_l.pdf) — André Seznec, CBP 2014. [Official CBP PDF](https://jilp.org/cbp2014/paper/AndreSeznec.pdf)
16b. [TAGE-SC-L Branch Predictors Again](tage/16b_2016_seznec_tage_sc_l_again.pdf) — André Seznec, CBP 2016. [Official CBP PDF](https://www.jilp.org/cbp2016/paper/AndreSeznecLimited.pdf)

## Modern Motivation

17. [Branch Prediction Is Not a Solved Problem: Measurements, Opportunities, and Future Directions](modern/17_2019_lin_tarsa_branch_prediction_not_solved.pdf) — Chit-Kwan Lin and Stephen J. Tarsa, IISWC 2019. [arXiv PDF](https://arxiv.org/pdf/1906.08170)

## CBP2025 Proceedings

The [official workshop program](https://ericrotenberg.wordpress.ncsu.edu/cbp2025-workshop-program/) lists nine public papers. All nine are included:

1. [TAGE-SC for CBP2025](cbp2025/01_seznec_tage_sc_for_cbp2025.pdf) — André Seznec. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final37-Seznec.pdf)
2. [A Deep Dive Into TAGE-SC-L](cbp2025/02_ros_deep_dive_tage_sc_l.pdf) — Alberto Ros. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final2-Ros.pdf)
3. [RUNLTS: Register-value-aware Predictor Utilizing Nested Large Tables](cbp2025/03_koizumi_et_al_runlts.pdf) — Toru Koizumi et al. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final44-Koizumi.pdf)
4. [LVCP: A Load Value Correlated Predictor for TAGE-SC-L](cbp2025/04_man_et_al_lvcp.pdf) — Yang Man et al. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final15-Man.pdf)
5. [PIP: An Ensemble of Programming-Idiom Predictors](cbp2025/05_mose_et_al_pip.pdf) — Karl H. Mose et al. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final19-Mose.pdf)
6. [TAGE-SC-L with a Code Structure Correlator](cbp2025/06_cai_et_al_code_structure_correlator.pdf) — Lingzhe Cai et al. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final27-Cai.pdf)
7. [Multiperspective Perceptron Predictor](cbp2025/07_jimenez_multiperspective_perceptron.pdf) — Daniel A. Jiménez. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final53-Jimenez.pdf)
8. [Taming Wild Branches: Overcoming Hard-to-Predict Branches Using the Bullseye Predictor](cbp2025/08_behrendt_et_al_bullseye.pdf) — Emet Behrendt, Shing Wai Pun, and Prashant J. Nair. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final36-Behrendt.pdf)
9. [Branch Prediction via Load Value Prediction: A Case of BALL](cbp2025/09_fan_ball_predictor.pdf) — Jun Fan. [Source](https://ericrotenberg.wordpress.ncsu.edu/files/2025/06/cbp2025-final56-Fan.pdf)

## CBP-NG 2026 Proceedings

CBP-NG explicitly evaluates accuracy, throughput, latency, energy, and implementation complexity. The [official workshop program](https://cbp-ng.bpchamp.com/program) lists seven accepted papers. All seven and the scoring document are included:

0. [A Scoring Metric for the CBP-NG Championship](cbp_ng_2026/00_michaud_vfs_scoring_metric.pdf) — Pierre Michaud. [Official repository source](https://github.com/AmpereComputing/cbp-ng/blob/main/docs/vfs.pdf)
1. [An Energy-Efficient Ahead-Pipelined TAGE Branch Predictor for CBP-NG](cbp_ng_2026/01_dang_rotenberg_ahead_pipelined_tage.pdf) — Nhat Dang and Eric Rotenberg. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Dang_Rotenberg-paper.pdf)
2. [Enhance Ahead-Pipelined N-Branch GShare with Tagged Tables](cbp_ng_2026/02_fan_ahead_pipelined_n_branch_gshare.pdf) — Jun Fan. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Fan-paper.pdf)
3. [Distilled Branch Predictors](cbp_ng_2026/03_sethumadhavan_distilled_branch_predictors.pdf) — Simha Sethumadhavan. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Sethumadhavan-paper.pdf)
4. [RABT: Run-Ahead Block TAGE](cbp_ng_2026/04_gupta_et_al_rabt.pdf) — Prakhar Gupta et al. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Gupta_et_al-paper.pdf)
5. [MORSL: Minimal-Overhead Rank-Based Predictor with Summation-Free Correction and Lazy Access](cbp_ng_2026/05_koizumi_et_al_morsl.pdf) — Toru Koizumi et al. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Koizumi_et_al-paper.pdf)
6. [Coding Agents as Design Searchers: An Autonomous TAGE Tuning Campaign for CBP-NG](cbp_ng_2026/06_pallan_coding_agents_tage_tuning.pdf) — Matt Pallan. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Pallan-paper.pdf)
7. [Offset-Free TAGE-SC: Conditional-Branch-Level Prediction for Wide Fetch Frontends](cbp_ng_2026/07_balivada_susarla_offset_free_tage_sc.pdf) — Yashwant Kumar Balivada and Sairam Viswanathan Susarla. [Proceedings source](https://archive.org/download/cbp-ng_proceedings/Balivada_Susarla-paper.pdf)

## Validation

- Every local file was recognized as PDF and parsed by `pdfinfo`; the 35 PDFs contain 339 pages in total. The scanned Lee–Smith technical report was checked page by page from rendered images; the other papers were checked against full-document text extraction and original-page rendering.
- The Chinese guide contains 35 independent paper chapters with section-ordered body coverage, text explanations of important figures and tables, clearly separated teaching commentary, and no embedded PDF-page images. Its local PDF links were resolved against the repository and the Markdown was parsed successfully.
- The collection contains 35 PDFs: 12 foundational papers, 5 O-GEHL/TAGE papers, 1 modern motivation paper, 9 CBP2025 papers, 7 CBP-NG papers, and 1 CBP-NG scoring document.
- Only publicly reachable author, university, conference, arXiv, workshop, or proceedings links were used.
