-- 处理重复行
CREATE TABLE Customer_Call_List_2 AS 
SELECT * FROM Customer_Call_List;

ALTER TABLE Customer_Call_List_2 ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

SELECT 
    *
FROM
    Customer_Call_List_2 c1
        JOIN
    (SELECT 
        CustomerID, MIN(id) AS keep_id
    FROM
        Customer_Call_List_2
    GROUP BY CustomerID) AS c2 ON c1.CustomerID = c2.CustomerID
        AND c1.id > c2.keep_id;

DELETE FROM Customer_Call_List_2 
WHERE
    id = 21;

-- 处理姓名列的乱七八糟问题
SET SQL_SAFE_UPDATES = 0;

UPDATE Customer_Call_List_2 
SET 
    First_Name = TRIM(First_Name),
    Last_Name = TRIM(Last_Name) ;


SELECT Last_Name,REGEXP_REPLACE(Last_Name, '^[/_.]+|[/_.]+$', '') AS cleaned_name
FROM Customer_Call_List_2 ;

-- 这条 SQL 命令会将 Last_Name 字段中开头和结尾的 /、_ 和 . 字符全部替换为空字符串（即删除它们）。
UPDATE Customer_Call_List_2 
SET 
    Last_Name = REGEXP_REPLACE(Last_Name, '^[/_.]+|[/_.]+$', '') ;

-- 电话号码
SELECT
Phone_Number,
REGEXP_REPLACE(Phone_Number, '[^0-9]', '') AS Cleaned_Phone_Number
FROM Customer_Call_List_2 ;

UPDATE Customer_Call_List_2 
SET 
    Phone_Number = REGEXP_REPLACE(Phone_Number, '[^0-9]', '') ;


-- 删除无用列
ALTER TABLE Customer_Call_List_2
DROP COLUMN Not_Useful_Column;

ALTER TABLE Customer_Call_List_2
DROP COLUMN `_2`;


-- 地址进行分列
SELECT 
    TRIM(SUBSTRING_INDEX(Address, ',', 1)) AS street
FROM Customer_Call_List_2;

SELECT 
    CASE 
        WHEN address LIKE '%,%' THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',', 2), ',', -1))
        ELSE NULL
    END AS city
FROM Customer_Call_List_2;

SELECT 
	CASE 
		WHEN TRIM(SUBSTRING_INDEX(Address, ',', -1)) REGEXP '^[0-9]+$' THEN TRIM(SUBSTRING_INDEX(Address, ',', -1)) -- 如果是数字，就认为是邮编
		ELSE NULL 
    END AS zipcode
FROM Customer_Call_List_2;


SELECT 
	Address,
    TRIM(SUBSTRING_INDEX(Address, ',', 1)) AS street,
    CASE 
        WHEN address LIKE '%,%' THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',', 2), ',', -1))
        ELSE NULL
    END AS city,
    CASE 
        WHEN TRIM(SUBSTRING_INDEX(Address, ',', -1)) REGEXP '^[0-9]+$' THEN TRIM(SUBSTRING_INDEX(Address, ',', -1))
        ELSE NULL 
    END AS zipcode
FROM Customer_Call_List_2;

ALTER TABLE Customer_Call_List_2
ADD COLUMN Street VARCHAR(255),
ADD COLUMN City VARCHAR(255),
ADD COLUMN Zipcode VARCHAR(20);

UPDATE Customer_Call_List_2
SET 
    Street = TRIM(SUBSTRING_INDEX(Address, ',', 1)),
    City = CASE 
              WHEN address LIKE '%,%' THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',', 2), ',', -1))
              ELSE NULL
          END,
    Zipcode = CASE 
                  WHEN TRIM(SUBSTRING_INDEX(Address, ',', -1)) REGEXP '^[0-9]+$' THEN TRIM(SUBSTRING_INDEX(Address, ',', -1))
                  ELSE NULL
              END;
              
-- Paying Customer 统一 yes/no 的格式
-- 列名 Paying Customer 中包含了空格，而 SQL 中空格会导致问题。在 SQL 中，如果列名包含空格，需要使用反引号（`）将其包围起来。

SELECT 
    `Paying Customer`,
    CASE 
        WHEN `Paying Customer` IN ('Yes', 'y') THEN 'Y'
        WHEN `Paying Customer` IN ('No', 'n') THEN 'N'
        ELSE null  
    END AS Unified_Paying_Customer
FROM Customer_Call_List_2;

UPDATE Customer_Call_List_2
SET `Paying Customer` = CASE 
                            WHEN `Paying Customer` IN ('Yes', 'y') THEN 'Y'
                            WHEN `Paying Customer` IN ('No', 'n') THEN 'N'
                            ELSE null 
                         END ;
                         
-- Do_Not_Contact 统一 yes/no 的格式
SELECT 
    Do_Not_Contact,
    CASE
        WHEN Do_Not_Contact IN ('Yes' , 'Y') THEN 'Y'
        WHEN Do_Not_Contact IN ('No' , 'N') THEN 'N'
        ELSE NULL
    END AS Unified_Do_Not_Contact
FROM
    Customer_Call_List_2;


UPDATE Customer_Call_List_2 
SET 
    Do_Not_Contact = CASE
        WHEN Do_Not_Contact IN ('Yes' , 'Y') THEN 'Y'
        WHEN Do_Not_Contact IN ('No' , 'N') THEN 'N'
        ELSE NULL
    END;


--  最后统一所有表格的null n/a 之类的

UPDATE Customer_Call_List_2
SET 
    Last_Name = CASE 
                WHEN Last_Name = '' OR Last_Name = 'N/a' THEN NULL
                ELSE Last_Name
              END,
   Phone_Number = CASE 
                WHEN Phone_Number = '' OR Phone_Number = 'N/a' THEN NULL
                ELSE Phone_Number
              END,
    Address = CASE 
                WHEN Address = '' OR Address = 'N/a' THEN NULL
                ELSE Address
              END,
    `Paying Customer` = CASE 
                WHEN `Paying Customer` = '' OR `Paying Customer` = 'N/a' THEN NULL
                ELSE `Paying Customer`
              END,   
     Do_Not_Contact = CASE 
                WHEN Do_Not_Contact = '' OR Do_Not_Contact = 'N/a' THEN NULL
                ELSE Do_Not_Contact
              END ;       
              
-- 最后删除一些列              
ALTER TABLE Customer_Call_List_2
DROP COLUMN `Address`;              
              
ALTER TABLE Customer_Call_List_2
DROP COLUMN `id`;   		
              
              