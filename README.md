# Chat2Me

An AI chat application based on OpenAI api.

基于 OpenAI api 的一款 AI 聊天软件。

## 简介

自学 3 天后用 Flutter 做出来的第一款软件，功能还不是很完善。如果有时间维护，会美化一下界面和完善一下其他功能。

目前只在 Web 和 Android 端做过测试。

**初次使用需要提供 OpenAI Key ！！**

如果在国内，仍然需要科学上网。

在设置里可以重置 OpenAI Key 。

## 截图

### Key 提交界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/submit_interface.jpg)

### 空对话界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/empty_chat_interface.jpg)

### 对话界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/chat_interface.jpg)

### 设置界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/settings_interface.jpg)

## 实现功能

目前仅实现了 Chat 功能。

### Chat 对话

暂时写死使用的是`gpt-3.5-turbo-0301`模型。

在 AI 回答右下角提供了本次回答使用的`tokens`数量和本次回答结束的**结束原因**（`finish_reason`）。

聊天窗口右下角的一个按钮可以**重置聊天**（清空聊天记忆）。

在设置里可以修改**生成温度**（`temperature`），用于修改 AI 的创造性程度。

## 待实现

1. 可修改**用户名**。
2. 可修改**主题配色**。
3. 实现**关于**界面。
4. 整个图标。

### Chat 对话

1. 保存对话历史记录，并可以通过历史记录聊天记忆继续聊天。（`SQLite`）
2. 可以修改用户说的话，使 AI 重新生成对话。（感觉没必要）
3. 可选 AI 模型，从网络获取你能用哪些模型。
