# Readme

這是使用Pitch分析音頻的正式版本code。

## 檔案說明

總共會有五個檔案，分別為：
- main.m 用來run整個程式，並且負責讀取音檔及呼叫其他功能函式
- find_5_Pitch.m 用於計算音高及五個要回傳的指標
- prepocess.m 用於做音檔的預處理
- stereo2mono.m 預處理呼叫的函式檔，處理雙聲道轉單聲道
- repet.m 預處理呼叫的函式檔，用於去除噪聲

## 執行方式

下載整包最終版本的檔案，然後在main.m裡面讀進想分析的音檔：

```matlab
% Read audio
inputAudio = 'sounds/music.wav';
[audio, audio_fs] = audioread(inputAudio);
```

找到這幾行程式碼，把 `'sounds/music.wav'` 改成想測的音檔。

以及目前定義高音區以及低音區分別為前20%的最高音高以及前20%的最低音高，若要修改其數值範圍定義在main.m檔中
```matlab
percentage = 0.2; %You can choose the percentage you what to define as high pitch section or low pitch section
```
將0.2修改成自己認定的數值就好

**Command Window顯示** 

整體程式正常執行會在Command Window顯示以下資訊：
```
Do Stereo to Mono...Elapsed time is 0.050499 seconds.
Do Remove background signal...Elapsed time is 0.606549 seconds.
Do Bandpass filter...Elapsed time is 38.307853 seconds.
Result for find_5_Pitch
Highest Pitch: 1175.642554 Hz
Lowest Pitch: 16.253051 Hz
Average Pitch: 264.618851 Hz
Average High Pitch: 647.186008 Hz
Average Low Pitch: 87.233482 Hz
```
會顯示目前預處理的步驟以及花費的時間，Bandpass filter會花費較久時間，但不超過50s，請耐心等候。
## 實作方法

首先這個main的組成是：

1. 讀檔案
2. 呼叫前處理函式，對音訊做前處理
3. 拿處理好的檔案算五個指標
4. 印出結果（測試用）

所以往後會依序說明怎麽做的、以及有哪些未成成或待測試的地方。

### 1. 前處理函式

寫在 `preprocess.m`

呼叫方法：`[audioFFT ,audioFreq, flatAudio] = preprocess(audio, audio_fs);`

* input: 音訊、sample rate
* output: FFT權重、FFT後的frequency conponent、處理好的音訊

#### 1.1 轉成單聲道

```matlab
% Stereo to mono
audio = stereo2mono(myAudio);
```

參考mathwork中的code，先做兩個聲道的相加，之後透過其左右聲道的原始峰值振幅應用於標準化的單聲道混音

#### 1.2 移除噪聲

```matlab
% Remove background signal
foreground = audio - repet.original(audio, audio_fs);
background = repet.original(audio, audio_fs);
audio = foreground;
```

這裡用 `repet.m` 處理，效果不怎樣。需要測試出更好的方法。

#### 1.3 濾除人耳聽不到的頻率
使用Bandpass filter，只保留人耳聽的到的頻率

```matlab
% 0.32 Bandpass filter specify passband frequencies of 20 Hz and 20000 Hz
audio = bandpass(audio,[20 20000],audio_fs);
```

**❗這裡也就是之後filter要插入的地方**。

處理好的audio會回傳回去，也會用這個處理好的audio繼續算fft。

#### 1.4 FFT 目前沒有用到 可供參考

從上個作業沿用至今，圖畫出來看起來應該對（？）

如果大家有時間再看又不要debug，但我也是從mathwork上看來的，相信開源力量大先pass（

這裡會算出要傳回去的audioFFT（各component的權重）、audioFreq（組成音訊的frequency component）

到這裡前處理完成！

---

### 2. 算五個指標

拿處理好的資料算。

函數寫在：`find_5_pitch.m`

呼叫方法：`[maxPitch, minPitch, meanPitch, meanMaxPitch, meanMinPitch]  = find_5_Pitch(flatAudio, audio_fs, percentage);`

* input: 處理後音訊、sample rate、percentage
* output: 五個指標

我們使用matlab內建的pitch函式做為音高的評估，Range的部分是參考人聲音域所設定的，其餘幾乎都是預設的參數

```matlab
[myPitch, idx] = pitch(audio, audio_fs, ...
            'Method','PEF', ...
            'WindowLength',round(audio_fs*0.08), ...
            'OverlapLength',round(audio_fs*(0.08-0.01)), ...
            'Range',[15,1200], ...
            'MedianFilterLength',3);
```

#### 2.1 找最高最低音高

```matlab
% Find highest Pitch
maxPitch = max(myPitch);

% Find lowest Pitch
minPitch = min(myPitch);
```

直接找最大和最小的 Pitch，直接使用Matlab內建的音高計算函式

注意這是假定我們資料已經處理得非常乾淨、假定一定不會取到噪音的情況。

未來不排除發現無法精準降噪，而需要改寫這部份code的情形。

#### 2.2 找平均

```matlab
% Find the mean Pitch
meanPitch = mean(myPitch);
```

#### 2.3 平均高音低音區

```matlab
% Sort the pitch from largest to smallest
Pitch_sorted_descend = sort(myPitch,descend);

% Calculate the number of samples to take in the top k%
num_descend = length(Pitch_sorted_descend);
num_to_take_descend = round(num_descend * k);

% Take the largest top k% pitch
meanMaxPitch = mean(Pitch_sorted_descend(1:num_to_take_descend));

```

這是算高音，低音一樣算法。

概念是將轉換成pitch的序列通過內建的sort函式由大到小排列or由小到大，並且得出需要取得的sample數量後，對排序後的pirch序列只取從開頭到sample數量那麼多的樣本數再做平均
舉由大到小排序的為例：就是從大到小排序列取得最高的前 k％ 樣本，之後作平均。

這樣計算應該沒有太大問題，就是差在每個人認為的高音區跟低音區好像不同，這比較是相對的高音，也就是依照歌曲的變化不同而計算出的。

## 結論

還可以再改善的：

1. 看能不能找出更好的filter，這會放在前處理函式0.2 part

   關於這部份，目前測試結果是，雖然repet聽起來不怎樣，但有用還是比沒用好

2. 目前因為還是會受到背景聲音的影響，雖然有實作出提取人聲的方式，但因為運行效率不高，平均需要五分鐘的時間，因此就先放棄。導致最高音高以及最低音高幾乎就是我們的音高range範圍極值