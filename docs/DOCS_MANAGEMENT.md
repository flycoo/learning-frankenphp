# 文档管理计划（课程化学习用）

## 目的
为 FrankenPHP 学习过程建立一套清晰的文档管理与课程化流程，使笔记、示例、练习和成果可追溯、可复现并便于评审。

## 目录与放置约定
- `docs/`: 课程材料、学习计划、管理类文档（当前文件存放处）。
- `docs/LEARNING_PLAN.md`: 学习路线与里程碑（课程大纲）。
- `docs/LESSONS/`: 每一课为单独目录 `lesson-01-<短名>/`，包含 `README.md`、`exercise/`、`solution/`、`notes.md`。
- `docs/EXERCISES/`: 可复用练习与自动化说明（脚本、输入、期望输出）。
- `frankenphp/testdata/` 与 `docs/demos/`: 示例代码与配置，课程中引用时请在 LESSON 的 README 中写明路径。

## 文件命名与模版
- Lesson 目录：`lesson-<NN>-<kebab-short-title>`（NN 两位数字）。
- Lesson `README.md` 模板要包含：目标、前置条件、步骤（可复制命令）、预期结果、检查点。 
- Exercise 描述需包含：输入、操作、验证命令、评分标准。

## 版本与分支策略（课程性工作流）
- 主线（`main`）：稳定材料与已验证示例。 
- 课程分支：每节课使用 `lesson/<NN>-<short-title>` 分支进行开发与提交。 
- 练习提交：学生在个人 fork/分支上完成练习，创建 PR 到课程分支用于评审。

## 提交与审阅规范
- 每次提交应包含关联的 LESSON/EXERCISE 路径与简短说明。
- 使用 `commit_changes.sh` 脚本提交整套变更（包含子模块），并在 PR 描述中列出检查点通过情况。

## 自动化与脚本
- 在每个 LESSON 中提供可一键运行的脚本（`run.sh` 或 `run_demo.sh`）示范如何：安装依赖、构建、运行 demo、执行测试。
- 推荐在 LESSON README 中列出关键命令（可复制粘贴）：
```bash
# 安装依赖（仅示例）
./docs/scripts/install_deps.sh

# 构建示例二进制
(cd frankenphp/caddy/frankenphp && go build -o frankenphp .)

# 运行 demo
curl http://127.0.0.1:80/
```

## 检查点与评分（课程化）
- 每课给出 3 个检查点（理解、动手、扩展）。
- 通过条件：能复现 demo 输出、代码改动能通过本课相关测试、提交 PR 并通过 code review。

## 元数据与索引
- 每个 LESSON 的 `README.md` 在顶部放置 YAML 风格元数据（标题、作者、时长、难度、依赖）。
- 在 `docs/index.md`（或 `docs/README.md`）维护课程目录与链接（可自动生成 TOC）。

## 复盘与维护节奏
- 每次课程后添加 `LESSON/notes.md` 总结学习要点与常见错误。
- 每月或每个 major 里程碑进行文档审查，修复陈旧命令或路径。

## 协作建议
- 课堂练习采用小 PR+Review 模式，教师在 PR 中给出标签：`grade/ok`、`grade/retry`、`needs-fix`。
- 对于代码示例，要求最小可运行改动且有清晰的回滚说明。

## 课程示例计划（与 `docs/LEARNING_PLAN.md` 对应）
- 课 1：环境准备与依赖（执行 `install_deps` 并记录输出与问题）。
- 课 2：构建与运行 Hello World（构建 `frankenphp`，运行 `phpinfo.php`）。
- 课 3：Worker 模式入门（运行 `worker.Caddyfile`，观察日志、断点）。
- 课 4：源码导读（`frankenphp.go` 的 `Init` / 线程模型）。
- 课 5：小练习（添加自定义 header，提交 PR）。

---
文件位置：`docs/DOCS_MANAGEMENT.md`（课程文档管理指南）。
