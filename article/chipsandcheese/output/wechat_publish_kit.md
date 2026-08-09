# WeChat Official Account Publishing Kit

## 1. Publication status

- Article file: `xuantie_c910_wechat_article_zh.md`
- Source article: *Alibaba/T-HEAD's Xuantie C910*
- Original author: Chester Lam
- Original platform: Chips and Cheese
- Original publication date: 2025-02-04
- Original URL: https://chipsandcheese.com/p/alibabat-heads-xuantie-c910
- Chinese version type: annotated translation with separately labeled editorial notes
- Current release gate: **written authorization still needs to be confirmed and recorded**

The supplied HTML shows ordinary copyright notices and no public Creative Commons or translation license. Source attribution is necessary but does not replace permission. Tencent's rules require published material to have a lawful source or necessary authorization, and the public-account rules prohibit unauthorized publication of another person's original article:

- Tencent intellectual-property policy: https://ipr.tencent.com/policy/content/1
- Tencent explanation of the “Original” declaration: https://ipr.tencent.com/policy/content/3
- CAC public-account information service rules: https://www.cac.gov.cn/2021-01/22/c_1612887880656609.htm

Do not publish the full translation until the authorization covers the text, the included figures, WeChat distribution, and any commercial features that will be enabled.

## 2. Copy-ready publishing fields

### Primary title

从 RTL 到实测：玄铁 C910 微结构深度拆解

### Alternative titles

1. 玄铁 C910 的前端、乱序执行与存储系统：一篇深度译注
2. Chips and Cheese 译注：玄铁 C910 微结构全景分析
3. 大 ROB 为什么没有换来更高吞吐？玄铁 C910 深度拆解

The primary title is recommended because it describes the method without presenting the author's performance judgment as an official conclusion.

### Author field

Use the Chinese editor's name or the public-account column name in the WeChat backend:

`〔中文译注者姓名 / 栏目名〕`

Keep “Original author: Chester Lam” in the visible source block at the start of the article. Do not replace the original author's name with the Chinese editor's name.

### Digest

Chester Lam 结合公开 RTL、定向微基准和 TH1520 实机测试，拆解玄铁 C910 的前端、分支预测、乱序执行、访存系统与多核互连。本文忠实保留原文观点，并补充证据边界和体系结构译注。

### Cover text

玄铁 C910 微结构拆解

Optional small text:

从 RTL 到 TH1520 实测

### “Read original” URL

https://chipsandcheese.com/p/alibabat-heads-xuantie-c910

Use this as the backend “阅读原文” link. Recheck it in preview before sending.

### Suggested tags

- RISC-V
- 玄铁 C910
- CPU 微架构
- 乱序执行
- Cache 与内存
- OpenC910 RTL

### Suggested column

体系结构译注

### Share text

从公开 RTL、微基准到 TH1520 实测，这篇译注系统梳理玄铁 C910 的前端、乱序后端、访存与多核互连，并严格区分官方资料、RTL 观察、作者实测和编者推断。

### Optional closing question

如果只能优先改一项，你会选择扩大调度与访存窗口，还是先降低 L2 延迟并提高带宽？

## 3. Required visible attribution

The article already begins with a source block. Before publication, replace both placeholders:

- `〔发布前填写姓名或公众号署名〕`
- `〔发布前填写授权方式与日期；未取得必要授权时不要发布全文〕`

Recommended authorization wording after permission is obtained:

> 中文译注与技术核查：张三 / 某某公众号
>
> 授权说明：经原作者 Chester Lam 于 2026-XX-XX 书面授权发布中文译注

Recommended copyright wording:

> 英文原文、原始图表及其中引用材料的权利归 Chester Lam、Chips and Cheese 与相应权利人所有。本中文译注依据书面授权发布，未经相应权利人许可不得二次转载。

If permission excludes some figures, remove those figures from the public version and adjust the surrounding text. Do not imply that the original author owns third-party figures quoted from Alibaba or other sources.

## 4. Original declaration and monetization

- WeChat “原创声明”: **do not enable** for this translated article.
- WeChat repost/authorization status: describe it as an authorized annotated translation after permission is obtained.
- Paid reading, advertisements, sponsorship, tips, and appreciation: keep disabled unless the permission explicitly covers commercial use.
- Do not use “official interpretation”, “official test”, or “official conclusion” in the title, cover, digest, or promotion.
- Keep the visible statement that this is third-party analysis rather than Alibaba/T-HEAD official material.

Tencent states that the Original mechanism is protected by strict rules and that unauthorized publication of another person's original article is content infringement. The CAC also requires reposted public-account content to identify the rights holder and a traceable source.

## 5. AI-assisted-content disclosure

This version was materially assisted by generative AI for Chinese expression, organization, mobile formatting, and static checking. Keep the visible AI statement near the beginning and use any AI-content declaration control provided by the current WeChat backend.

Copy-ready statement:

> AI 辅助说明：本文使用生成式人工智能协助中文表达整理、移动端排版和静态核对；技术数据、观点归属和最终发布内容由发布者人工复核。

The current national labeling rules define AI-generated/synthesized text as covered content and require users publishing such content through network information services to declare it and use the platform's labeling function. The rules have been in force since 2025-09-01:

- CAC AI-generated-content labeling rules: https://www.cac.gov.cn/2025-03/14/c_1743654684782215.htm
- GB 45438-2025 information page: https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F32EA2A561F1886CD8D606513512D547

## 6. Cover and image package

### Cover recommendation

Prefer a newly drawn cover rather than directly using a source figure:

- Aspect ratio: 2.35:1
- Practical working size: 900 × 383 px
- Main text: “玄铁 C910 微结构拆解”
- Visual: dark-blue or graphite background, simple CPU block/line art, one highlighted data-flow path
- Avoid placing the Alibaba/T-HEAD logo on a newly created cover unless its use is authorized
- Keep important text and the CPU subject away from the outer edges because the backend may crop previews

The dimensions above are practical editor recommendations, not a substitute for the current backend preview. Also prepare a centered 1:1 crop if the account's message-list or sharing view requests it.

### Body images

- Figure files: 30
- Figure order: 01–30
- Formats: JPG and PNG
- Every image has a visible Chinese caption in the WeChat article
- Wide Markdown tables have been converted to vertical lists for mobile reading

Upload the images in filename order. Do not rely on Markdown alt text as a caption; keep the italic caption paragraph under each image.

Several figures contain text or diagrams copied or annotated from other works. Ensure the publication authorization or applicable quotation basis covers each image. Figure 29 is low resolution, but its exact values are also transcribed in text, so do not enlarge it aggressively.

## 7. Recommended mobile typography

These are layout recommendations rather than platform rules:

- Body: 15–16 px
- Line height: 1.7–1.8
- Main section heading: 18–20 px, bold
- Subheading: 16–17 px, bold
- Figure caption: 12–13 px, gray, centered
- Paragraph spacing: 10–14 px
- Body color: dark gray rather than pure black
- Code, signal names, and bit ranges: use a monospace or light-gray inline-code style
- Keep each paragraph to roughly 2–5 mobile-screen lines where possible

Do not use animated decorations, fake system notices, fake play buttons, or unrelated link cards. WeChat's 2024 public-account guidance specifically identified misleading graphics, hidden conclusions, and unrelated link destinations as problematic.

## 8. Authorization request template

### English

Subject: Permission request for a Chinese annotated translation of your Xuantie C910 article

Dear Chester,

I would like to publish a Chinese annotated translation of your article “Alibaba/T-HEAD's Xuantie C910” on the WeChat Official Account “[account name]”.

The Chinese version will:

- identify you as the original author and Chips and Cheese as the original publisher;
- place the original URL prominently at the beginning and in WeChat's “Read original” field;
- preserve your technical claims, measurements, comparisons, uncertainty, and conclusions;
- label added architecture explanations and RTL checks as editorial notes;
- include the article's 30 technical figures, subject to your permission and any third-party rights;
- be published [non-commercially / with the following monetization: ...].

May I have permission to translate, adapt for Chinese mobile formatting, reproduce the authorized figures, and publish this version on WeChat? Please also let me know whether you require any specific wording, image exclusions, review before publication, or a link back after publication.

Thank you,

[Name]

[WeChat Official Account]

[Email]

[Planned publication date]

### Chinese record

主题：申请发布《Alibaba/T-HEAD's Xuantie C910》中文译注

Chester 您好：

我希望在微信公众号“〔账号名称〕”发布您文章《Alibaba/T-HEAD's Xuantie C910》的中文译注与体系结构解读。发布版本会显著标注您的作者身份、Chips and Cheese 首发平台和原文链接，忠实保留技术观点、数据、比较条件、不确定性与结论；新增解释将明确标为译注或编者核查。

拟申请的授权范围包括：中文翻译、适配移动端的结构与格式调整、在微信公众号公开传播、在授权范围内使用原文技术图，以及〔非商业发布 / 具体商业功能〕。如需删减图片、使用指定版权文案、发布前送审或发布后回传链接，请一并告知。

谢谢。

〔姓名、公众号、邮箱、预计发布日期〕

Save the full authorization conversation, date, account identity, scope, and any image restrictions with the publication record.

## 9. Backend publishing checklist

1. Obtain and archive written authorization.
2. Fill the translator/editor and authorization placeholders in the article.
3. Paste the article through a Markdown-to-WeChat converter or rebuild the heading styles in the official editor.
4. Upload all retained figures in order and verify each visible caption.
5. Enter the primary title, author field, digest, and cover.
6. Set “阅读原文” to the Chips and Cheese URL.
7. Leave “原创声明” disabled.
8. Enable the available AI-content declaration and retain the visible AI statement.
9. Disable monetization features unless explicitly authorized.
10. Preview on at least one iOS and one Android phone.
11. Verify inline code, bit ranges such as `[11:4]`, multiplication symbols, superscripts, units, and arrows.
12. Check that no figure is cropped, blurred, reordered, or detached from its caption.
13. Confirm that every platform comparison is attributed to the original author and still carries its comparability caveat.
14. Confirm the final title, digest, cover, source URL, and authorization wording before sending.
15. After publication, save the public URL, screenshots, publication time, final exported article, and authorization record.

## 10. Final publication record

Fill this section after publication:

- WeChat account:
- Publisher/editor:
- Authorization provider:
- Authorization date:
- Authorization scope:
- Commercial features enabled:
- Publication date and time:
- Public article URL:
- Original URL verified:
- AI label enabled:
- Final exported copy:
- Notes or corrections:
