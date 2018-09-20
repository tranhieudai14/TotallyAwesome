# TotallyAwesome
1. Outline
- In viewDidLoad(), the app will send http request to API to get data from server. Next, it will store data which are images into an array and put it into tableView.
- tableView will use a cell created by xib files as its own cell. A cell has an image inside.
- When click on a cell, it will push the same tableView into navigationController and reload new data.
2. Third-party
- None
3. Issues
- Design UI by xib files and make reference between element and outlet in source code it's harder for debugging than design UI by code.
