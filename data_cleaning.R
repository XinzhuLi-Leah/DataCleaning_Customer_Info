setwd('/Users/lixinzhu/Desktop/李馨竹-sql/客户电话清洗-sql')
data <- read.csv('/Users/lixinzhu/Desktop/李馨竹-sql/客户电话清洗-sql/Customer Call List.csv')

# 删除重复行 删掉了一行
data <- data[!duplicated(data), ]
print(data)
#下面几个方法也是可以的哦
#df_unique <- unique(df)
#df_unique <- df %>% distinct()

#删掉不需要的列,知道列的索引的前提下，如果列太多了，那就不是很推荐
data <- data[c(-8,-9,-10)]
#下面几个方法也是可以的哦
#df$B <- NULL
#df_new <- subset(df, select = -B)

#去掉姓名无效字符
library(stringr)

data$Last_Name <- str_trim(data$Last_Name)  # 去除首尾空格
data$First_Name <- str_trim(data$First_Name)  # 去除首尾空格

data$Last_Name <- str_replace_all(data$Last_Name , "[123._/]", "")  # 清理特定字符
data$First_Name <- str_replace_all(data$First_Name, "[123._/]", "")  # 清理特定字符


#处理电话号码中间的连字符乱七八糟问题
# 对于- 需要用到使用双反斜杠 \\- 进行转义
data$Phone_Number<- str_replace_all(data$Phone_Number , "[|._/\\-]", "") 

#拆分列 拆分地址
library(tidyr)
data <- data %>% 
  tidyr::separate(Address, into = c("Street", "City", "Zipcode"), sep = ",", fill = "right")


#统一 yes no
library(dplyr)

data $Paying.Customer <- case_when(
  data $Paying.Customer %in% c("Yes", "y", "YES", "Y") ~ "Y",
  data $Paying.Customer %in% c("No", "n", "NO", "N") ~ "N",
  TRUE ~ data$Paying.Customer  # 其他情况保持不变
)


data $Do_Not_Contact <- case_when(
  data $Do_Not_Contact %in% c("Yes", "y", "YES", "Y") ~ "Y",
  data $Do_Not_Contact %in% c("No", "n", "NO", "N") ~ "N",
  TRUE ~ data$Do_Not_Contact  # 其他情况保持不变
)

#处理缺失值
data[data == "Na" | data == "None" | data == "N/a" | data == "NA"| data == " "] <- NA  # 统一变成 NA
data[is.na(data)] <- ""  # 要改成空白
#data[data %in% c("Na", "None", "N/a", "NA", " ")] <- NA
#data <- replace(data, data %in% c("Na", "None", "N/a", "NA", " "), NA)