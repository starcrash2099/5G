@echo off
echo ========================================
echo  GitHub Upload Script
echo  Project: AI Emergency Communication Gateway
echo  Author: PRIYAM GANGULI
echo ========================================
echo.

echo Step 1: Initializing Git repository...
git init
if errorlevel 1 (
    echo ERROR: Git initialization failed. Is Git installed?
    pause
    exit /b 1
)
echo SUCCESS: Git initialized
echo.

echo Step 2: Adding all files...
git add .
if errorlevel 1 (
    echo ERROR: Failed to add files
    pause
    exit /b 1
)
echo SUCCESS: Files added
echo.

echo Step 3: Creating first commit...
git commit -m "Initial commit: AI Emergency Communication Gateway v1.0 by Priyam Ganguli"
if errorlevel 1 (
    echo ERROR: Commit failed
    pause
    exit /b 1
)
echo SUCCESS: Commit created
echo.

echo Step 4: Adding remote repository...
git remote add origin https://github.com/priyamganguli/drone-emergency-gateway.git
if errorlevel 1 (
    echo WARNING: Remote might already exist, trying to continue...
    git remote set-url origin https://github.com/priyamganguli/drone-emergency-gateway.git
)
echo SUCCESS: Remote configured
echo.

echo Step 5: Pushing to GitHub...
echo NOTE: You may be asked to login to GitHub
git branch -M main
git push -u origin main
if errorlevel 1 (
    echo ERROR: Push failed. Check your GitHub credentials
    echo.
    echo Troubleshooting:
    echo 1. Make sure you created the repository on GitHub first
    echo 2. Check your GitHub username and password
    echo 3. You may need a Personal Access Token instead of password
    pause
    exit /b 1
)
echo SUCCESS: Pushed to GitHub!
echo.

echo Step 6: Creating release tag...
git tag -a v1.0.0 -m "Initial release: AI Emergency Communication Gateway"
git push origin v1.0.0
if errorlevel 1 (
    echo WARNING: Tag push failed, but main code is uploaded
)
echo.

echo ========================================
echo  UPLOAD COMPLETE!
echo ========================================
echo.
echo Your repository is now live at:
echo https://github.com/priyamganguli/drone-emergency-gateway
echo.
echo Next steps:
echo 1. Visit your repository on GitHub
echo 2. Add topics/tags (see UPLOAD_TO_GITHUB.md)
echo 3. Create a release (see UPLOAD_TO_GITHUB.md)
echo 4. Share your work!
echo.
pause
