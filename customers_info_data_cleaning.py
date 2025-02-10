import pandas as pd

df = pd.read_excel(r"/Users/lixinzhu/Desktop/李馨竹-sql/客户电话清洗-sql/Customer Call List.xlsx")
df

print(df.info())

# 处理重复值
# sql 里面还是蛮复杂的
df = df.drop_duplicates()
df

# 删掉不需要的列
df = df.drop(columns = "Not_Useful_Column")
df

# 去除姓名中的首尾空格 只能是首尾空格哦！
# sql 里面用到的是trim ,ltrim,rtrim
df['First_Name'] = df['First_Name'].str.strip()
df['Last_Name'] = df['Last_Name'].str.strip()
print(df)

# 这个命令会从每个 "Last_Name" 列的字符串的开头和结尾去掉 "1"、"2"、"3"、"."、"_" 和 "/" 这些字符，但不会去掉字符串中间的这些字符。
df["Last_Name"] = df["Last_Name"].str.strip("123._/")
df
# 如果你想去掉字符串中间的这些字符，你应该用 str.replace() 并结合正则表达式来实现：
# 前缀 r 代表原始字符串（raw string），它告诉 Python 解释器不要处理字符串中的转义字符（比如 \）。当你写正则表达式时，某些字符（如反斜杠 \）在普通字符串中有特殊含义，而在原始字符串中，反斜杠会被当作普通字符处理。
df["Last_Name"] = df["Last_Name"].str.replace(r"[123._/]", "", regex=True)


#对电话号码进行乱七八糟的格式修改,sql里面使用的是regexp_replace,其实还蛮类似的
df["Phone_Number"] = df["Phone_Number"].str.replace(r"[-/|]", "", regex=True)
df

# 地址的分列,对比sql来说真的方便很多,sql  里面使用的的substring_index
# expand=True 会将拆分结果展开为多个列。每个拆分出来的部分都会成为一个新的列。结果是一个 DataFrame，其中每一列都包含拆分后的数据。
df[['Street', 'City', 'Zipcode']] = df['Address'].str.split(',', expand=True)
df


#然后统一yes no 的格式 ,sql里面使用的是case when
df["Do_Not_Contact"] = df["Do_Not_Contact"].str.replace('Yes','Y')

df["Do_Not_Contact"] = df["Do_Not_Contact"].str.replace('No','N')
df

df["Paying Customer"] = df["Paying Customer"].str.replace('Yes','Y')

df["Paying Customer"] = df["Paying Customer"].str.replace('No','N')
df


# 处理没有信息的值
print(df.isnull())
print(df == '')

# np.nan 是 NumPy（numpy 库）中的 缺失值（NaN, Not a Number） 的表示方式，相当于 SQL 里的 NULL
# 	•	np.nan 是 NumPy 里的 真正缺失值，相当于 SQL 里的 NULL，不会被当作普通字符串处理。
# 	•	‘NA’、‘N/A’、‘None’ 这些是手输的字符串，必须手动转换成 np.nan 才能被 pandas 识别为缺失值。

import numpy as np
df.replace(['NA', 'None', 'Na','n-a', 'N/A','N/a', 'NaN', 'none', ''], np.nan, inplace=True)
df

df=df.fillna('')
df
# 处理这种没有信息的值。在sql 里面是case when 的,得一列一列去case when 还比较麻烦的