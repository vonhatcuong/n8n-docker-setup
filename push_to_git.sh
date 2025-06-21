#!/bin/bash
# Template script để push lên GitHub
# Thay YOUR_GITHUB_URL bằng URL thực tế

echo "🔗 Adding remote repository..."
# git remote add origin YOUR_GITHUB_URL

echo "🚀 Pushing to GitHub..."
# git branch -M main
# git push -u origin main

echo ""
echo "📝 Example commands (thay YOUR_USERNAME và YOUR_REPO):"
echo ""
echo "# Nếu repository là public:"
echo "git remote add origin https://github.com/YOUR_USERNAME/n8n-docker-setup.git"
echo ""
echo "# Nếu repository là private hoặc bạn dùng SSH:"
echo "git remote add origin git@github.com:YOUR_USERNAME/n8n-docker-setup.git"
echo ""
echo "# Push code:"
echo "git branch -M main"
echo "git push -u origin main"
echo ""
echo "✅ Sau khi chạy xong, repository sẽ có sẵn tại GitHub!"
