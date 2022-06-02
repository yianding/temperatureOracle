# 通用去中心化預言機
這個項目本來是用於一個練習項目，設計一個溫度預言機。做完之後，覺得可以做成一個通用的預言機。可以用於任何鏈下數據上鏈。比如：股票指數，金融產品價格，天氣，災難，選舉結果等等。
## 基本設計思想
這是一個完全去中心化的通用預言機，沒有任何中心化的管理方，採取社區自治的方式來維護通用預言機的運轉。統一上傳數據的格式。統一調用接口。

### 數據格式
任何上傳的數據，都採用兩部分，label,value。label是數據的標籤，value是一個uint256的大整數。

比如:要做上證的收盤價格指數

label 可以是:{'20220602','Shanghai SE Composite Index'},value:230098

含義：2022年6月2日，上證指數，2300.98點

上傳數據接口： PostOracleData(string label,uint256 value)

獲取數據接口:  GetOracleData(string label) public view (uint256 value)

### 預言機礦工
所有上傳數據的人稱之爲預言機礦工，

1、向智能合約繳納一定金額的哈耶幣（在其他區塊鏈上使用對應的加密貨幣）作爲押金才能成爲礦工。

2、礦工自由自願根據市場需要上傳誠實數據，並且獲得盈利。

3、礦工社區自治，礦工的加入需要經過一定比例的礦工投票才能加入，避免一人持有多個礦工賬戶。

### 經濟模型
預言機產生的數據，其他智能合約讀取，需要支付使用費。不同的數據而有不同的定價。定價由全體礦工投票漲跌。這是礦工收入的一個來源。

其次，上傳不真實數據的礦工，會喪失自己的部分押金。這部分押金，由其他誠實礦工均分。這也是誠實礦工的盈利來源之一。

### 如何判斷是否是誠實礦工
每一個數據，由多個礦工上傳，落在均方差正負5%以內的數據，證明是誠實礦工，超出這個範圍的爲非誠實礦工。非誠實礦工會失去自己的押金由其他誠實礦工均分。

未完待續

如過您想參與這個項目，可以發郵件給我:yianding@gmail.com