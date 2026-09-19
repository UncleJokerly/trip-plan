# trip-plan — 2026 十一晋北自驾之旅

家庭旅行行程页的发布仓库。任何电脑上的 AI 助手（ZCode / Claude Code / 其他 agent）或人，都可以按本说明修改并发布。

## 文件说明

| 文件 | 角色 |
|---|---|
| `trip.html` | **行程页源文件（唯一需要编辑的文件）** |
| `travel-plan.zip` | 发布产物：手机下载解压即得 trip.html（由 publish.sh 生成，勿手改） |
| `trip.pdf` | 发布产物：打印版（由 publish.sh 生成，勿手改） |

## 修改并发布（任何电脑，3 步）

```bash
git clone https://gitee.com/UncleJokerly/trip-plan.git   # 公开仓库，克隆不需要登录
cd trip-plan
# → 编辑 trip.html（人或 AI 助手都行）
bash publish.sh "改了什么的一句话说明"
```

`publish.sh` 会自动：重新打包 zip → 重新生成 PDF（本机有 Edge/Chrome 时）→ 推送 gitee + github → 清 jsdelivr 缓存。

**推送登录**：gitee 推送需要输入账号密码（或提前配好 SSH key / 凭据管理器）；github 推送需要该电脑能访问 GitHub（代理、SSH key 或 HTTPS+令牌任一）。**github 必须推成功**——jsdelivr 的 PDF 直链读的是 github 仓库，推不上 github 直链就不会更新。实在配不了 github 的电脑：把改动留在 gitee，让主电脑拉取补推。

## 给 AI 助手的设计约束（改版式前必读）

- **单文件自包含**：所有 CSS/JS 内联；图片以 base64 内嵌（`data:image/jpeg;base64,...`）；**不引用任何外部资源**（无 CDN 字体/脚本/图片），因为页面要在手机离线、弱网环境下打开
- **移动优先**：按 **420px 视口宽度**设计，目标设备是微信内置浏览器（Xiaomi 15 / iPhone 均可）
- **适老化**：正文字号要大、行高宽松、信息分块清晰——读者是父母辈（60+）
- **主题**：金五台主题，主色金色系（`#A9721A`）
- 改完后务必在浏览器 420px 宽度下自查一遍布局再发布

## 直链备忘

- **PDF（点开即看，永远最新）**：https://cdn.jsdelivr.net/gh/UncleJokerly/trip-plan@main/trip.pdf
- **手机 zip 下载**：https://gitee.com/UncleJokerly/trip-plan/raw/main/travel-plan.zip
- Gitee 仓库：https://gitee.com/UncleJokerly/trip-plan （主仓库，国内直连）
- GitHub 仓库：https://github.com/UncleJokerly/trip-plan （CDN 源，需代理访问）

注意：Gitee 的 raw 链接对新推送有几分钟缓存延迟；gitee/github 的 html raw 链接一律是"文本显示"（不会渲染成网页，也不会触发下载），这是平台策略。
