# YYSlider
a custom slider with popover

[USAGE]

```
struct ContentView: View {
    @State var currentValue:CGFloat = 0
    var body: some View {
        YYSliderView(currentValue: $currentValue,showPopover: true,popoverDirection: .top)
    }
}

```
![](https://github.com/ChuanqingYang/YYSlider/blob/main/preview.png)
