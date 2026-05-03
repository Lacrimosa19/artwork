import torch
import torch.nn as nn

# 定义一个简单的神经网络模型
class SimpleNN(nn.Module):
    def __init__(self):
        super(SimpleNN, self).__init__()
        # 定义一个输入层到隐藏层的全连接层
        self.fc1 = nn.Linear(3, 3)  # 输入 3 个特征，输出 3 个特征
        # 定义一个隐藏层1到隐藏层2的全连接层
        self.fc2 = nn.Linear(3, 3)  # 输入 3 个特征，输出 3 个特征
        # 定义一个隐藏层2到输出层的全连接层
        self.fc3 = nn.Linear(3, 1)  # 输入 3 个特征，输出 1 个预测值
    
    def forward(self, x):
        # 前向传播过程
        x = torch.relu(self.fc1(x))  # 使用 ReLU 激活函数
        x = torch.relu(self.fc2(x))  # 使用 ReLU 激活函数
        x = self.fc3(x)  # 输出层
        return x

# 创建模型实例
model = SimpleNN()

# 打印模型
print(model)