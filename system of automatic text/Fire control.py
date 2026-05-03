import math

class FireControl:
    #火炮控制系统
    def __init__(self):
      #火炮参数 (105毫米榴弹炮)
        self.g = 9.8    #重力加速度
        self. muzzle_vel = 600    #炮弹初速（米/秒）

    def calculate_elevation(self, target_distance):
        #计算炮口仰角
        #使用真空弹道公式：距离 = （初速^2 * sin(2 * 仰角)）/ 重力加速度
        #反推仰角：仰角 = arcsin((距离 * 重力加速度) / (初速^2)) / 2
        
        #最大射程
        max_range = (self.muzzle_vel ** 2) / self.g  
        if target_distance > max_range:
            return None  #目标超出最大射程
        
        #计算仰角
        sin_2_theta = (target_distance * self.g) / (self.muzzle_vel ** 2)
        #限制取值
        sin_2_theta = min(1, max(-1, sin_2_theta))
        theta = math.asin(sin_2_theta) / 2

        return math.degrees(theta)  #返回仰角（度）
    def calculate_range(self,elevalution_deg):
        #计算射程
        theta = math.radians(elevalution_deg)
        range = (self.muzzle_vel ** 2) * math.sin(2 * theta) / self.g
        return range  #返回射程（米）
    
def main():
    print('='*30)
    print('火控计算机(105毫米榴弹炮)')
    print('='*30)

    #示例
    fc = FireControl()
    while True:
        print("\n---新目标---")
        try:
            #输入目标距离
            dist_input = input("请输入目标距离（米，或输入'q'退出）：")
            if dist_input.lower() == 'q':
                print("退出火控计算机。")
                break
            target_distance = float(dist_input)
            #计算仰角
            elevation = fc.calculate_elevation(target_distance)
            if elevation is not None:
                #输出射击诸元
                print('射击诸元:')
                print(f"\n目标距离: {target_distance:.2f} 米")
                print(f"炮口仰角: {elevation:.2f} 度")

                #验证射程
                actual_range = fc.calculate_range(elevation)
                print(f"预计射程: {actual_range:.0f} 米")
                print(f"射程误差: {abs(actual_range - target_distance):.0f} 米")
            else:
                print("目标超出最大射程，无法计算仰角。")
        except ValueError:
            print("输入无效，请输入一个数字或'q'退出。")
        except KeyboardInterrupt:
            print("\n退出火控计算机。")
            break
if __name__ == "__main__":    main()
                


        