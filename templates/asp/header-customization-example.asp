<%@ Page Language="C#" %>
<%--
  header-customization-example.asp - Example ASP Header Template Customization

  Purpose: Demonstrates common customizations to page headers in ePublisher output
  Based on: WebWorks Reverb 2.0 format

  Usage:
    1. Copy the actual Connect.asp or header file from installation
    2. Locate the header section in that file
    3. Apply modifications from this example as needed
    4. Save to: Formats\WebWorks Reverb 2.0\Pages\[filename].asp
              or Targets\[TargetName]\Pages\[filename].asp

  Common Customizations:
    - Add company logo
    - Modify toolbar layout
    - Add custom navigation links
    - Include custom JavaScript
    - Add analytics tracking code

  Modified: 2025-01-27 - Example customizations
--%>

<%--
  EXAMPLE 1: Add Company Logo to Header

  Replace the default logo with your company logo
--%>

<div class="header-logo">
    <%-- CUSTOM: Company logo --%>
    <a href="index.html">
        <img src="images/company-logo.png"
             alt="Company Name"
             width="200"
             height="60" />
    </a>
</div>

<%--
  EXAMPLE 2: Add Product Name and Version

  Display product information in the header
--%>

<div class="header-product-info">
    <h1 class="product-name">Product Name</h1>
    <span class="product-version">Version 2.0</span>
</div>

<%--
  EXAMPLE 3: Custom Navigation Links

  Add quick links to important pages or external resources
--%>

<div class="header-quick-links">
    <ul>
        <li><a href="index.html">Home</a></li>
        <li><a href="getting-started.html">Getting Started</a></li>
        <li><a href="faq.html">FAQ</a></li>
        <li><a href="https://www.example.com/support" target="_blank">Support</a></li>
        <li><a href="https://www.example.com/downloads" target="_blank">Downloads</a></li>
    </ul>
</div>

<%--
  EXAMPLE 4: Search Box Customization

  Modify the search box appearance or behavior
--%>

<div class="header-search">
    <form id="search-form" role="search">
        <label for="search-input" class="sr-only">Search Documentation</label>
        <input type="text"
               id="search-input"
               name="q"
               placeholder="Search documentation..."
               aria-label="Search"
               autocomplete="off" />
        <button type="submit" aria-label="Submit search">
            <span class="search-icon">🔍</span>
        </button>
    </form>
</div>

<%--
  EXAMPLE 5: Breadcrumb Navigation

  Add breadcrumb trail for better navigation context
--%>

<div class="breadcrumb-container">
    <nav aria-label="Breadcrumb">
        <ol class="breadcrumb">
            <li><a href="index.html">Home</a></li>
            <li><a href="user-guide.html">User Guide</a></li>
            <li class="active" aria-current="page">Current Page</li>
        </ol>
    </nav>
</div>

<%--
  EXAMPLE 6: Custom Toolbar Buttons

  Add custom buttons to the toolbar
--%>

<div class="toolbar-custom-buttons">
    <%-- Print button --%>
    <button class="toolbar-button" onclick="window.print();" title="Print this page">
        <span class="button-icon">🖨️</span>
        <span class="button-label">Print</span>
    </button>

    <%-- PDF download button --%>
    <a href="downloads/documentation.pdf"
       class="toolbar-button"
       download
       title="Download PDF">
        <span class="button-icon">📄</span>
        <span class="button-label">Download PDF</span>
    </a>

    <%-- Feedback button --%>
    <a href="https://www.example.com/feedback"
       class="toolbar-button"
       target="_blank"
       title="Send Feedback">
        <span class="button-icon">💬</span>
        <span class="button-label">Feedback</span>
    </a>
</div>

<%--
  EXAMPLE 7: Language Selector

  Add language selection dropdown for multilingual documentation
--%>

<div class="language-selector">
    <label for="language-select" class="sr-only">Select Language</label>
    <select id="language-select" onchange="switchLanguage(this.value)">
        <option value="en" selected>English</option>
        <option value="es">Español</option>
        <option value="fr">Français</option>
        <option value="de">Deutsch</option>
        <option value="ja">日本語</option>
    </select>
</div>

<%--
  EXAMPLE 8: Version Selector

  Allow users to switch between different documentation versions
--%>

<div class="version-selector">
    <label for="version-select">Version:</label>
    <select id="version-select" onchange="switchVersion(this.value)">
        <option value="2.0" selected>2.0 (Latest)</option>
        <option value="1.9">1.9</option>
        <option value="1.8">1.8</option>
        <option value="1.7">1.7 (Legacy)</option>
    </select>
</div>

<%--
  EXAMPLE 9: Custom JavaScript Functions

  Add JavaScript for custom functionality
--%>

<script type="text/javascript">
// CUSTOM: Language switching function
function switchLanguage(lang) {
    // Redirect to language-specific documentation
    var currentPage = window.location.pathname.split('/').pop();
    window.location.href = '/' + lang + '/' + currentPage;
}

// CUSTOM: Version switching function
function switchVersion(version) {
    // Redirect to version-specific documentation
    var currentPage = window.location.pathname.split('/').pop();
    window.location.href = '/docs/v' + version + '/' + currentPage;
}

// CUSTOM: Initialize header functionality
document.addEventListener('DOMContentLoaded', function() {
    // Highlight active navigation item
    var currentPath = window.location.pathname;
    document.querySelectorAll('.header-quick-links a').forEach(function(link) {
        if (link.getAttribute('href') === currentPath) {
            link.classList.add('active');
        }
    });

    // Add search box auto-complete functionality
    var searchInput = document.getElementById('search-input');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            // Implement search suggestions here
            console.log('Search query:', this.value);
        });
    }
});
</script>

<%--
  EXAMPLE 10: Analytics Tracking Code

  Add Google Analytics or other tracking
--%>

<script type="text/javascript">
// CUSTOM: Google Analytics tracking
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-XXXXXXXXX-X', 'auto');  // Replace with your tracking ID
ga('send', 'pageview');
</script>

<%--
  EXAMPLE 11: Custom CSS for Header

  Add inline styles specific to header customizations
--%>

<style type="text/css">
/* CUSTOM: Header customization styles */

.header-logo {
    float: left;
    margin-right: 2em;
}

.header-product-info {
    float: left;
    margin-top: 1em;
}

.header-product-info .product-name {
    font-size: 1.5em;
    margin: 0;
    color: #007ACC;
}

.header-product-info .product-version {
    font-size: 0.9em;
    color: #666;
}

.header-quick-links {
    float: right;
}

.header-quick-links ul {
    list-style: none;
    margin: 0;
    padding: 0;
}

.header-quick-links li {
    display: inline-block;
    margin-left: 1em;
}

.header-quick-links a {
    text-decoration: none;
    color: #333;
    padding: 0.5em 1em;
    border-radius: 3px;
    transition: background-color 0.2s;
}

.header-quick-links a:hover,
.header-quick-links a.active {
    background-color: #007ACC;
    color: #FFF;
}

.sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0,0,0,0);
    white-space: nowrap;
    border: 0;
}
</style>

<%--
  NOTES:

  - This is an EXAMPLE file showing common customization patterns
  - Copy the actual ASP file from your installation before modifying
  - Test all customizations after implementation
  - Document all changes with comments
  - Consider responsive design for mobile devices
  - Validate HTML output for accessibility
  - Test JavaScript in different browsers

--%>
