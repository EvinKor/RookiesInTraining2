# 🎓 Manage Classes Feature - Complete Guide

## 📋 Overview
New centralized interface for teachers to manage their classes with:
- **Class Selection** - Choose class or create new one
- **Forum Tab** - Class discussions (coming soon)
- **Storymode Tab** - Create/manage learning levels

---

## 🎯 How It Works

### **1. From Teacher Dashboard:**
Click **"Manage Classes"** button → Goes to `manage_classes.aspx`

### **2. Class Selection Screen:**
Shows all your classes as clickable cards:
- Each card shows class name, description, student count, level count
- **"Create New Class"** card to make a new class
- Click any class to manage it

### **3. Class Management (2 Tabs):**

#### **Forum Tab** (Active by default)
- View and create discussion posts
- Students and teachers can participate
- Posts can be pinned or locked
- (Basic structure in place, full feature coming soon)

#### **Storymode Tab**  
- View all learning levels for the class
- **"Create New Level"** button
- Each level shows:
  - Level number and title
  - Description
  - Duration and XP
  - Published status
  - **Edit**, **Slides**, **Quiz** buttons

---

## ✨ Features

### **Creating a New Level in Storymode:**

1. **Click "Create New Level"** in Storymode tab
2. **Fill in the form:**
   - **Level Number** - Auto-increments (1, 2, 3...)
   - **Level Title** - e.g., "Introduction to Variables"
   - **Description** - What students will learn
   - **Estimated Minutes** - How long it takes
   - **XP Reward** - Points awarded
   - **Upload Material** - PDF or PowerPoint (optional)
   
3. **Quiz Details (Required):**
   - **Quiz Title** - Auto-suggests "Level X Quiz"
   - **Quiz Mode** - Story or Battle
   - **Time Limit** - Minutes allowed
   - **Passing Score** - Percentage to pass

4. **Click "✓ Create Level with Quiz"**
5. Level and quiz created automatically!
6. Page reloads showing new level

### **Managing Existing Levels:**
- **Edit** - Modify level details
- **Slides** - Manage custom slides
- **Quiz** - Edit quiz questions

---

## 🗄️ Database Structure

### **New Tables Added:**

**ForumPosts:**
- Post title and content
- Can be pinned or locked
- Belongs to a class
- Created by user (teacher/student)

**ForumReplies:**
- Reply content
- Linked to a post
- Created by user

---

## 📂 File Structure

```
Pages/teacher/
├── dashboard_teacher.aspx (Updated - links to manage_classes)
├── manage_classes.aspx (NEW - Main management interface)
├── manage_classes.aspx.cs (NEW - Backend logic)
├── manage_classes.aspx.designer.cs (NEW - Designer file)
├── teacher_create_module.aspx (Wizard for full module)
├── class_detail.aspx (Detail view for advanced management)
└── ... other pages
```

---

## 🎮 User Flow

```
Teacher Dashboard
    ↓
[Manage Classes] Button
    ↓
manage_classes.aspx
    ├─ Choose "Create New Class" → teacher_create_module.aspx
    └─ Choose existing class
        ├─ Forum Tab → Class discussions
        └─ Storymode Tab → Create/manage levels
            ├─ Create New Level → Modal opens
            ├─ Edit Level → (coming soon)
            ├─ Manage Slides → Opens slide editor
            └─ Edit Quiz → Go to add_questions.aspx
```

---

## 🚀 How to Use

### **For Teachers:**

**Step 1: Access Manage Classes**
- Login as teacher
- Click **"Manage Classes"** on dashboard

**Step 2: Select a Class**
- Click on any class card
- OR click "Create New Class" to make a new one

**Step 3: Use Storymode Tab**
- Click **"Class Storymode"** tab
- Click **"Create New Level"**
- Fill in level and quiz details
- Upload PDF/PowerPoint OR plan to add slides later
- Click **"Create Level with Quiz"**

**Step 4: Add Content**
- Click **"Slides"** to add custom slides
- Click **"Quiz"** to add quiz questions

**Step 5: Use Forum Tab** (Coming Soon)
- Create discussion posts
- Pin important announcements
- Enable student discussions

---

## 🆕 What's Different from Previous Structure?

### **Old Structure:**
- teacher_browse_classes.aspx → Lists classes
- Click class → class_detail.aspx (all details)

### **New Structure:**
- **manage_classes.aspx** → Central hub
  - Forum tab → Discussions
  - Storymode tab → Learning content
- **class_detail.aspx** → Advanced management (still available)

**Both structures work!** Choose based on your preference:
- **manage_classes** - Simpler, focused on Forum + Storymode
- **class_detail** - More advanced, all tabs (Levels, Students, Quizzes, Resources)

---

## 📊 Database Updates Needed

**Run these SQL scripts in order:**

1. **CLEANUP_QUIZZES_FINAL.sql** - Fix quiz duplicates
2. **ALL_TABLES_FORMATTED.sql** - (Or just the new tables 16-17 if others exist)

**New tables:**
- ForumPosts
- ForumReplies

---

## ✅ What's Implemented

✅ **Class selection interface** with beautiful cards  
✅ **Forum tab structure** (posts feature coming soon)  
✅ **Storymode tab** fully functional  
✅ **Create new levels** with quiz in one step  
✅ **Level list** with edit/slides/quiz buttons  
✅ **Dashboard integration** - Manage Classes button  
✅ **Database schema** for forum features  
✅ **Auto-incrementing level numbers**  
✅ **Auto-suggesting quiz titles**  

---

## 🎉 Summary

Your teachers now have a powerful **Manage Classes** interface where they can:

1. **Select a class** from a visual gallery
2. **Switch between Forum and Storymode tabs**
3. **Create learning levels** directly in Storymode
4. **Each level automatically has 1 quiz**
5. **Add slides or upload PDF/PowerPoint**
6. **Manage everything** in one place!

**Rebuild and test the new Manage Classes feature!** 🚀

