# BioGrammatics Tailwind CSS Design System Guide

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Changing Colors & Backgrounds](#changing-colors--backgrounds)
3. [Typography](#typography)
4. [Components](#components)
5. [Layout](#layout)
6. [Best Practices](#best-practices)

---

## 🚀 Quick Start

### What's Different
Your Tailwind setup now uses **CSS custom properties** (like Wix) for easy theme customization. Change one variable, update everywhere.

### File Location
All design tokens are in: `app/assets/tailwind/application.css`

---

## 🎨 Changing Colors & Backgrounds

### Change Brand Color (Quick Rebrand)
Edit lines 11-21 in `application.css`:

```css
/* Change these hex values to rebrand */
--color-brand-50: #f0f4f1;   /* Lightest tint */
--color-brand-600: #2c5530;  /* Main brand color */
--color-brand-900: #112215;  /* Darkest shade */
```

### Using Theme Background Classes

Add these classes to any section/div:

```erb
<!-- Light backgrounds -->
<div class="bg-theme-light">Pure white background</div>
<div class="bg-theme-subtle">Light gray (default)</div>
<div class="bg-theme-muted">Slightly darker gray</div>

<!-- Accent backgrounds -->
<div class="bg-theme-primary">Brand green with white text</div>
<div class="bg-theme-primary-light">Light green tint</div>

<!-- Dark backgrounds -->
<div class="bg-theme-dark">Charcoal with white text</div>
<div class="bg-theme-darker">Almost black</div>
```

### Gradients

```erb
<div class="gradient-primary">Green gradient</div>
<div class="gradient-subtle">Subtle gray gradient</div>
```

### Change Body Background
In `application.css` line 119:
```css
body {
  background-color: var(--color-gray-50);  /* Change this */
}
```

Or add class to body in layout:
```erb
<body class="bg-theme-light">  <!-- or bg-white, bg-gray-100, etc -->
```

---

## ✍️ Typography

### Font Family
Using **Inter** font (modern, professional, excellent for UI)

To change font family, edit line 46:
```css
--font-family-sans: Inter, sans-serif;
```

Popular alternatives:
- `'Helvetica Neue', Helvetica, Arial, sans-serif` (Clean, minimal)
- `'SF Pro', -apple-system, sans-serif` (Apple-style)
- `'Poppins', sans-serif` (Geometric, friendly)
- `'Roboto', sans-serif` (Material Design)

### Heading Hierarchy

Headings are automatically styled:

```erb
<h1>Page Title</h1>       <!-- 48px, bold -->
<h2>Section Heading</h2>  <!-- 36px, bold -->
<h3>Subsection</h3>       <!-- 30px, semibold -->
<h4>Card Title</h4>       <!-- 24px, semibold -->
<h5>Small Heading</h5>    <!-- 20px, semibold -->
<h6>Tiny Heading</h6>     <!-- 18px, semibold -->
```

All have proper letter-spacing and line-height built in!

### Body Text

```erb
<p>Normal paragraph text</p>  <!-- 16px, relaxed line-height -->
```

### Custom Font Sizes

```erb
<span class="text-xs">12px</span>
<span class="text-sm">14px</span>
<span class="text-base">16px</span>
<span class="text-lg">18px</span>
<span class="text-xl">20px</span>
<span class="text-2xl">24px</span>
<span class="text-3xl">30px</span>
<span class="text-4xl">36px</span>
<span class="text-5xl">48px</span>
```

---

## 🧩 Components

### Buttons

```erb
<!-- Primary action button -->
<%= link_to "Get Started", path, class: "btn-primary" %>

<!-- Secondary button -->
<%= link_to "Learn More", path, class: "btn-secondary" %>

<!-- Accent button -->
<%= link_to "Try Now", path, class: "btn-accent" %>

<!-- Outline button -->
<%= link_to "Contact", path, class: "btn-outline" %>

<!-- Ghost button (minimal) -->
<%= link_to "Cancel", path, class: "btn-ghost" %>

<!-- Size variants -->
<%= link_to "Small", path, class: "btn-primary btn-sm" %>
<%= link_to "Large", path, class: "btn-primary btn-lg" %>
```

### Cards

```erb
<!-- Basic card -->
<div class="card">
  <h3>Card Title</h3>
  <p>Card content</p>
</div>

<!-- Card with hover effect -->
<div class="card-hover">
  <h3>Hover to lift</h3>
</div>

<!-- Interactive card (clickable) -->
<div class="card-interactive">
  <h3>Click me</h3>
</div>

<!-- Flat card (no border) -->
<div class="card-flat">
  <h3>Minimal</h3>
</div>

<!-- Elevated card (shadow, no border) -->
<div class="card-elevated">
  <h3>Floating</h3>
</div>
```

### Badges

```erb
<span class="badge-primary">New</span>
<span class="badge-secondary">Beta</span>
<span class="badge-success">Available</span>
<span class="badge-warning">Low Stock</span>
<span class="badge-danger">Sold Out</span>
<span class="badge-info">Info</span>
```

### Alerts

```erb
<div class="alert-info">
  <i class="bi bi-info-circle"></i>
  Informational message
</div>

<div class="alert-success">
  <i class="bi bi-check-circle"></i>
  Success message
</div>

<div class="alert-warning">
  <i class="bi bi-exclamation-triangle"></i>
  Warning message
</div>

<div class="alert-error">
  <i class="bi bi-x-circle"></i>
  Error message
</div>
```

### Forms

```erb
<%= form_with model: @object do |f| %>
  <div class="mb-4">
    <%= f.label :name, class: "form-label" %>
    <%= f.text_field :name, class: "form-input", placeholder: "Enter name" %>
    <% if @object.errors[:name].any? %>
      <p class="form-error"><%= @object.errors[:name].first %></p>
    <% end %>
    <p class="form-help">This is a helpful hint</p>
  </div>

  <div class="mb-4">
    <%= f.label :bio, class: "form-label" %>
    <%= f.text_area :bio, class: "form-textarea", rows: 4 %>
  </div>

  <div class="mb-4">
    <%= f.label :category, class: "form-label" %>
    <%= f.select :category, options, {}, class: "form-select" %>
  </div>

  <%= f.submit "Save", class: "btn-primary" %>
<% end %>
```

---

## 📐 Layout

### Containers

```erb
<!-- Standard width (1280px max) -->
<div class="container-custom">
  Content here
</div>

<!-- Narrow width (896px max) - good for reading -->
<div class="container-narrow">
  Article content
</div>

<!-- Wide width (1536px max) -->
<div class="container-wide">
  Dashboard content
</div>

<!-- Full width with padding -->
<div class="container-fluid">
  Full width content
</div>
```

### Sections

```erb
<!-- Standard section spacing -->
<section class="section">
  <div class="container-custom">
    Content
  </div>
</section>

<!-- Small section spacing -->
<section class="section-sm">
  Content
</section>

<!-- Large section spacing -->
<section class="section-lg">
  Content
</section>
```

### Example Page Layout

```erb
<!-- Hero Section -->
<div class="bg-gradient-to-br from-gray-50 to-white py-16 border-b">
  <div class="container-custom">
    <h1>Page Title</h1>
    <p class="text-xl text-gray-600">Subtitle</p>
  </div>
</div>

<!-- Content Section -->
<section class="section">
  <div class="container-custom">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="card-hover">
        <h3>Feature 1</h3>
        <p>Description</p>
      </div>
      <div class="card-hover">
        <h3>Feature 2</h3>
        <p>Description</p>
      </div>
      <div class="card-hover">
        <h3>Feature 3</h3>
        <p>Description</p>
      </div>
    </div>
  </div>
</section>

<!-- Call to Action -->
<section class="section bg-theme-primary">
  <div class="container-custom text-center">
    <h2>Ready to Get Started?</h2>
    <p class="text-lg mb-6">Join hundreds of researchers</p>
    <%= link_to "Sign Up Now", signup_path, class: "btn-secondary" %>
  </div>
</section>
```

---

## 💡 Best Practices

### 1. Use Semantic Components

❌ **Don't:**
```erb
<a href="#" class="inline-flex items-center px-6 py-3 bg-bio-green text-white rounded-lg hover:bg-bio-green-dark">
  Click me
</a>
```

✅ **Do:**
```erb
<%= link_to "Click me", path, class: "btn-primary" %>
```

### 2. Consistent Spacing

Use the spacing scale:
- `gap-4` or `gap-6` for grid gaps
- `mb-4` or `mb-6` for margins
- `p-4` or `p-6` for padding

### 3. Color Usage

- **Text**: Use `text-gray-700` for body, `text-charcoal` for headings
- **Backgrounds**: Use theme classes (`bg-theme-*`) for easy changes
- **Borders**: Use `border-gray-200` for subtle, `border-gray-300` for prominent

### 4. Responsive Design

Always think mobile-first:

```erb
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <!-- 1 column on mobile, 2 on tablet, 3 on desktop -->
</div>

<h1 class="text-3xl md:text-4xl lg:text-5xl">
  <!-- Responsive font sizes -->
</h1>
```

### 5. Hover States

Cards and buttons have built-in hover effects. For custom:

```erb
<div class="transition-all duration-200 hover:-translate-y-1 hover:shadow-lg">
  Smooth hover effect
</div>
```

---

## 🔧 Common Customizations

### Change Primary Color from Green to Blue

In `application.css`:
```css
--color-bio-green: #1e40af;       /* Blue 700 */
--color-bio-green-light: #3b82f6; /* Blue 500 */
--color-bio-green-dark: #1e3a8a;  /* Blue 900 */
```

### Change Default Background from Gray to White

```css
body {
  background-color: white;  /* Instead of var(--color-gray-50) */
}
```

### Add Custom Gradient

```css
.gradient-custom {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

### Increase Border Radius Globally

```css
--radius-lg: 1rem;     /* Make cards more rounded */
--radius-xl: 1.5rem;   /* Even more rounded */
```

---

## 📱 Mobile Responsiveness

All components are mobile-responsive by default. Key breakpoints:

- `sm:` 640px (phones landscape)
- `md:` 768px (tablets)
- `lg:` 1024px (laptops)
- `xl:` 1280px (desktops)
- `2xl:` 1536px (large desktops)

Example:
```erb
<div class="text-sm md:text-base lg:text-lg">
  Responsive text size
</div>

<div class="p-4 md:p-6 lg:p-8">
  Responsive padding
</div>
```

---

## 🎯 Quick Reference Card

| Need | Class |
|------|-------|
| Primary button | `btn-primary` |
| Card with hover | `card-hover` |
| Container | `container-custom` |
| Section spacing | `section` |
| Form input | `form-input` |
| Success badge | `badge-success` |
| Info alert | `alert-info` |
| White background | `bg-theme-light` |
| Brand background | `bg-theme-primary` |

---

## 🚀 Next Steps

1. **Explore examples**: Look at existing pages (vectors, strains, protein pathway)
2. **Experiment**: Try different `bg-theme-*` classes on sections
3. **Customize**: Change brand colors in `application.css`
4. **Build**: Use component classes for new features

Need help? The design system is fully documented in the CSS file with comments!
