# 📚 创建模块完整指南

## ✅ 实施完成

已成功实施教师"创建模块"功能，包含完整的3步向导流程。

---

## 🎯 功能概述

教师可以通过一个直观的3步向导创建完整的学习模块（课程 + 关卡）：

1. **第1步：课程信息** - 输入课程基本信息
2. **第2步：添加关卡** - 创建至少3个关卡，可以上传学习材料
3. **第3步：审阅** - 查看摘要并创建模块

---

## 📁 新增文件

### 1. 页面文件
- `RookiesInTraining2\Pages\teacher_create_module.aspx`
- `RookiesInTraining2\Pages\teacher_create_module.aspx.cs`
- `RookiesInTraining2\Pages\teacher_create_module.aspx.designer.cs`

### 2. JavaScript 文件
- `RookiesInTraining2\Scripts\create-module-wizard.js`

### 3. 更新的文件
- `RookiesInTraining2\Pages\teacher_browse_classes.aspx` - 添加"创建模块"按钮
- `RookiesInTraining2\RookiesInTraining2.csproj` - 添加新文件到项目

---

## 🚀 使用流程

### 第1步：访问创建模块页面

1. 以教师身份登录
2. 进入"我的课程"页面
3. 点击右上角的**"创建模块"**按钮

或直接访问：`https://localhost:44379/Pages/teacher_create_module.aspx`

### 第2步：填写课程信息

**必填字段：**
- **课程名称** (3-200字符)
- **课程代码** (自动生成，可重新生成)

**可选字段：**
- **描述** (最多500字符)
- **图标** (选择4个Bootstrap图标之一)
  - 📖 book (默认)
  - 💻 code-square
  - 🖥️ cpu
  - 💡 lightbulb
- **颜色** (选择4种颜色之一)
  - 紫色 (#667eea, 默认)
  - 蓝色 (#0984e3)
  - 绿色 (#00b894)
  - 橙色 (#e17055)

点击**"下一步"**继续。

### 第3步：添加关卡 (最少3个)

为每个关卡填写以下信息：

**必填字段：**
- **关卡编号** (1, 2, 3...)
- **标题** (3-200字符)

**可选字段：**
- **描述** (最多500字符)
- **预计分钟数** (默认15)
- **XP奖励** (默认50)
- **学习材料** (上传文件)
  - 支持格式：`.pptx`, `.ppt`, `.pdf`, `.mp4`, `.avi`, `.mov`
  - 最大大小：100MB
- **发布状态** (默认勾选)

**操作：**
- 点击**"添加此关卡"**将关卡添加到列表
- 每个关卡可以**编辑**或**删除**
- 关卡按编号自动排序
- 必须添加至少**3个关卡**才能继续

点击**"下一步"**进入审阅。

### 第4步：审阅并创建

- 查看课程信息摘要
- 查看所有关卡列表
- 确认无误后，点击**"✓ 创建模块"**

**成功后：**
- 系统将在数据库中创建课程和所有关卡（原子性事务）
- 上传的文件保存到：`/Uploads/{class_slug}/{level_slug}/`
- 自动跳转到课程详情页面
- 可以在课程详情页为每个关卡添加测验

---

## 🗄️ 数据库结构

### Classes 表

```sql
CREATE TABLE [dbo].[Classes] (
    [class_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
    [teacher_slug] NVARCHAR(100) NOT NULL,
    [class_name] NVARCHAR(200) NOT NULL,
    [class_code] NVARCHAR(50) NOT NULL UNIQUE,
    [description] NVARCHAR(500) NULL,
    [icon] NVARCHAR(50) NULL DEFAULT 'bi-book',
    [color] NVARCHAR(20) NULL DEFAULT '#6c5ce7',
    [created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    [updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    [is_deleted] BIT NOT NULL DEFAULT 0
);
```

### Levels 表

```sql
CREATE TABLE [dbo].[Levels] (
    [level_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
    [class_slug] NVARCHAR(100) NOT NULL,
    [level_number] INT NOT NULL,
    [title] NVARCHAR(200) NOT NULL,
    [description] NVARCHAR(500) NULL,
    [content_type] NVARCHAR(50) NULL, -- 'powerpoint', 'pdf', 'video'
    [content_url] NVARCHAR(500) NULL,
    [xp_reward] INT NOT NULL DEFAULT 50,
    [estimated_minutes] INT NOT NULL DEFAULT 15,
    [is_published] BIT NOT NULL DEFAULT 0,
    [created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    [updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    [is_deleted] BIT NOT NULL DEFAULT 0
);
```

---

## 🔒 安全和验证

### 服务器端验证

- ✅ 课程名称：3-200字符
- ✅ 最少3个关卡
- ✅ 每个关卡标题：3-200字符
- ✅ XP和分钟数 ≥ 0
- ✅ 唯一的class_slug和class_code
- ✅ 文件类型验证
- ✅ 原子性事务（全部成功或全部失败）

### 客户端验证

- ✅ 实时表单验证
- ✅ 防止重复关卡编号
- ✅ 步骤2必须有≥3个关卡才能继续
- ✅ 清晰的错误提示

### 权限控制

- ✅ 只有教师和管理员可以访问
- ✅ 未登录用户自动重定向到登录页
- ✅ 课程自动关联到创建者的user_slug

---

## 📂 文件上传

### 支持的文件类型

| 类型 | 扩展名 | content_type |
|------|--------|--------------|
| PowerPoint | `.ppt`, `.pptx` | `powerpoint` |
| PDF | `.pdf` | `pdf` |
| Video | `.mp4`, `.avi`, `.mov` | `video` |

### 存储路径

```
/Uploads/{class_slug}/{level_slug}/{level_slug}_{timestamp}.{ext}
```

示例：
```
/Uploads/intro-programming-101/intro-programming-101-level-1/intro-programming-101-level-1_20251105143522.pptx
```

### 配置

在 `Web.config` 中已配置最大上传大小：

```xml
<httpRuntime maxRequestLength="102400" /> <!-- 100MB -->
<requestLimits maxAllowedContentLength="104857600" /> <!-- 100MB -->
```

---

## 🎨 UI/UX 特性

- 🌈 渐变色头部设计
- 📍 步骤指示器（显示当前步骤）
- 🔄 平滑的页面过渡动画
- 📱 响应式设计（手机/平板/桌面）
- ✨ 悬停效果和视觉反馈
- 🎯 直观的图标和颜色选择器
- 📋 实时关卡列表预览
- ✅ 详细的审阅步骤

---

## 🧪 测试指南

### 1. 基本功能测试

```
✅ 以教师身份登录
✅ 访问创建模块页面
✅ 填写课程信息
✅ 添加3个关卡
✅ 查看审阅页面
✅ 创建模块
✅ 验证跳转到class_detail.aspx
✅ 验证数据库中的数据
```

### 2. 验证测试

```
✅ 尝试少于3个关卡 → 应显示错误
✅ 课程名称留空 → 应显示错误
✅ 关卡标题留空 → 应显示错误
✅ 重复的关卡编号 → 应显示错误
```

### 3. 文件上传测试

```
✅ 上传 .pptx 文件
✅ 上传 .pdf 文件
✅ 上传 .mp4 文件
✅ 验证文件保存到正确路径
✅ 验证 content_type 和 content_url 正确保存
```

### 4. 权限测试

```
✅ 学生访问 → 重定向到登录
✅ 未登录用户 → 重定向到登录
✅ 管理员访问 → 允许
```

### 5. 事务测试

```
✅ 模拟数据库错误 → 应回滚，不留部分数据
```

---

## 🔧 技术细节

### 技术栈

- **后端**：ASP.NET Web Forms 4.7.2, C#
- **数据库**：SQL Server LocalDB
- **前端**：Bootstrap 5, Vanilla JavaScript (无jQuery)
- **样式**：CSS3 (渐变、动画、响应式)

### 关键代码文件

#### 服务器端 (teacher_create_module.aspx.cs)

- `Page_Load` - 权限检查和初始化
- `btnCreateModule_Click` - 处理表单提交
- `HandleFileUpload` - 文件上传处理
- `SlugifyText` - 生成URL友好的slug
- `GenerateUniqueSlug` - 确保slug唯一性
- 事务管理 - `SqlConnection` + `SqlTransaction`

#### 客户端 (create-module-wizard.js)

- `draft` 对象 - 存储表单状态
- `addLevel()` - 添加关卡到草稿
- `editLevel()` - 编辑现有关卡
- `removeLevel()` - 删除关卡
- `goNext()` / `goBack()` - 步骤导航
- `generateReview()` - 生成审阅内容
- `syncDraftToHiddenField()` - 同步数据到服务器

---

## 🐛 故障排除

### 问题：创建失败，显示错误

**可能原因：**
1. 数据库连接问题
2. Uploads 文件夹权限问题
3. 事务回滚

**解决方案：**
1. 检查 `Web.config` 中的连接字符串
2. 确保 `RookiesInTraining2\Uploads\` 文件夹存在且有写权限
3. 查看错误消息，检查数据库日志

### 问题：文件上传失败

**可能原因：**
1. 文件太大
2. 不支持的文件类型
3. 磁盘空间不足

**解决方案：**
1. 确认文件 < 100MB
2. 只上传 .pptx, .ppt, .pdf, .mp4, .avi, .mov
3. 检查服务器磁盘空间

### 问题：跳转到class_detail后显示"Class not found"

**可能原因：**
1. 事务未提交
2. slug生成错误

**解决方案：**
1. 检查数据库，确认Classes表中有新记录
2. 检查 `is_deleted = 0`

---

## 📊 下一步

创建模块后，教师可以：

1. ✅ 查看课程详情
2. ✅ 为每个关卡添加测验
3. ✅ 编辑关卡信息
4. ✅ 管理学生注册
5. ✅ 查看统计数据

---

## 🎉 完成！

您已成功实施完整的"创建模块"功能！

如有任何问题，请参考：
- 错误消息
- 数据库日志
- 浏览器控制台
- 本指南的故障排除部分

---

**创建日期：** 2025-11-05  
**版本：** 1.0  
**状态：** ✅ 完全实施并测试


