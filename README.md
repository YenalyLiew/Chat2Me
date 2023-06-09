# Chat2Me

![](https://github.com/YenalyLiew/Chat2Me/blob/master/assets/logo/ctm_launcher_round.png)

An AI chat application based on OpenAI api.

基于 OpenAI api 的一款 AI 对话软件。

## 简介

使用 MVVM 架构（`Model, View, Provider`）编写，功能还不是很完善。如果有时间维护，会美化一下界面和完善一下其他功能。

目前只在 Web 和 Android 端做过测试。

**初次使用需要提供 OpenAI Key ，不是开箱即用的那种。**

如果在国内，仍然需要科学上网。

## 截图

### Key 提交界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/submit_interface.jpg)

### 空对话界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/empty_chat_interface.jpg)

### 对话界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/chat_interface.jpg)

### 对话历史记录界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/chat_history_interface.jpg)

### 设置界面

![](https://github.com/YenalyLiew/Chat2Me/blob/master/screenshot/settings_interface.jpg)

## 实现功能

在设置里可以重置 OpenAI Key 。

目前仅实现了 Chat 功能。

### Chat 对话

暂时写死使用的是`gpt-3.5-turbo`模型。

在 AI 回答右下角提供了本次回答使用的`tokens`数量，本次回答结束的**结束原因**（`finish_reason`）和时间。

对话会储存在历史记录里，并可以在历史记录里重新加载之前的对话。

#### 对话窗口

（由上到下）

1. 回到顶部。
2. 重置对话（清空对话记忆）。

#### 设置

（Chat 一栏由上到下）

1. **全局指令**（`Global directive`）。比如说你想让他成为一个猫娘，可以直接从这里给他下指令，而不必每次都从对话窗口告诉他。这是我自己起的名字，官方把这个称作**系统角色**（`System role`）对话。
2. **生成温度**（`Temperature`）。用于修改 AI 的创造性程度（0.0 ~ 2.0）。
3. **核采样**（`Top_p Sampling`）。一种替代温度采样的方法，称为核采样，其中模型考虑具有`top_p`概率质量的 token 的结果。
4. **最大 token 数**（`Max Token`）。聊天完成时要生成的最大 token 数。
5. **存在惩罚**（`Presence penalty`）。正值会根据到目前为止新 token 是否出现在文本中来惩罚它们，从而增加模型谈论新主题的可能性。
6. **频率惩罚**（`Frequency penalty`）。正值会根据新 token 在文本中的现有频率对其进行惩罚，从而降低模型逐字重复同一行的可能性。

## 待实现

1. 可修改**用户名**。
2. 可修改**主题配色**。

### Chat 对话

1. 可以修改用户说的话，使 AI 重新生成对话。（感觉没必要）
2. 可选 AI 模型，从网络获取你能用哪些模型。
