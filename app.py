import streamlit as st
import pandas as pd

st.set_page_config(page_title="IntercepTrak Proposal", layout="wide")

# 页眉
st.title("📡 IntercepTrak: Locating GPS Jamming Sources")
st.markdown("Project focused on enhancing GPS spoofing and jamming detection using machine learning techniques.")

st.subheader("👥 Project Team")

# Mentor 名片
st.markdown("#### 🧑‍🏫 Mentor")
with st.container():
    st.markdown(
        """
        <div style="border:1px solid #ccc; border-radius:10px; padding:15px; margin-bottom:10px; background-color:#f9f9f9">
            <strong>Dr. Chim, Tat Wing</strong><br>
            <span>Professor & Project Supervisor</span>
        </div>
        """,
        unsafe_allow_html=True
    )

# 成员卡片
st.markdown("#### 👨‍💻 Team Members")

cols = st.columns(2)

member_info = [
    {
        "name": "Wang Kai",
        "role": "Team Leader",
        "id": "3036411657",
        "email": "wangkai2024@connect.hku.hk"
    },
    {
        "name": "Zhang Junchi",
        "role": "Team Member",
        "id": "3036425634",
        "email": "u3642563@connect.hku.hk"
    },
    {
        "name": "Luo Wei",
        "role": "Team Member",
        "id": "3036381539",
        "email": "u3638153@connect.hku.hk"
    },
    {
        "name": "Lai Yin-yu",
        "role": "Team Member",
        "id": "3036030594",
        "email": "u3603059@connect.hku.hk"
    }
]

# 每两个一行，展示成员信息
for i in range(0, len(member_info), 2):
    cols = st.columns(2)
    for j in range(2):
        if i + j < len(member_info):
            with cols[j]:
                member = member_info[i + j]
                st.markdown(
                    f"""
                    <div style="border:1px solid #ccc; border-radius:10px; padding:15px; margin-bottom:10px; background-color:#ffffff">
                        <strong>{member['name']}</strong><br>
                        <span>{member['role']}</span><br>
                        <span>ID: {member['id']}</span><br>
                        <span>Email: {member['email']}</span>
                    </div>
                    """,
                    unsafe_allow_html=True
                )

# 进度表
st.subheader("📅 Project Milestones")

# Milestone 数据
milestones = [
    {"task": "Collect airplane & cargo ship locations", "date": "2025-02-01", "progress": 100},
    {"task": "Collect GPS signal data", "date": "2025-03-15", "progress": 100},
    {"task": "Collect spoofing & jamming signals", "date": "2025-03-30", "progress": 100},
    {"task": "Data augmentation", "date": "2025-04-15", "progress": 100},
    {"task": "Preprocessing & data balancing", "date": "2025-04-30", "progress": 100},
    {"task": "Train traditional ML model", "date": "2025-05-20", "progress": 50},
    {"task": "Train enhanced model", "date": "2025-06-01", "progress": 0},
    {"task": "Fine-tune & optimize", "date": "2025-06-25", "progress": 0},
    {"task": "Explore future work", "date": "2025-07-04", "progress": 0},
    {"task": "Write final report", "date": "2025-07-14", "progress": 0},
]

# 平均进度
avg = sum([m["progress"] for m in milestones]) / len(milestones)
milestones.append({"task": "Average Progress", "date": "", "progress": avg})

# 样式模板
template = """
<div style="width: 70%; margin: 0 auto; padding: 12px 0;">
  <!-- 上部：任务名与截止日期 -->
  <div style="display: flex; justify-content: space-between;">
    <div style="font-weight: bold;">{task}</div>
    <div style="color: gray;">(Due: {date})</div>
  </div>

  <!-- 中部：进度条 -->
  <div style="margin-top: 6px;">
    <div style="background-color: #e0e0e0; border-radius: 10px; height: 18px; width: 100%;">
      <div style="background-color: {bar_color}; width: {progress}%; height: 100%; border-radius: 10px;"></div>
    </div>
  </div>

  <!-- 下部：状态标识 -->
  <div style="margin-top: 6px; font-weight: bold; color: {text_color};">
    {icon} {status}
  </div>
</div>
"""



# 状态函数
def get_status_style(progress):
    if progress == 100:
        return "✅", "Completed", "#2ecc71", "green"
    elif progress > 0:
        return "🟡", "In Progress", "#f39c12", "orange"
    else:
        return "⬜", "Not Started", "#bdc3c7", "gray"


# 渲染进度
for m in milestones:
    icon, status, bar_color, text_color = get_status_style(m["progress"])
    st.markdown(template.format(
        icon=icon,
        status=status,
        task=m["task"],
        date=m["date"],
        progress=m["progress"],
        bar_color=bar_color,
        text_color=text_color
    ), unsafe_allow_html=True)


st.subheader("📘 Project Summary")

# Abstract
with st.expander("📌 **Abstract**"):
    st.markdown("""
    GPS spoofing and jamming present critical risks to UAV operations. This project introduces a machine learning approach 
    to classify and detect such threats by transforming GPS signals into spectral graphs and training models on public datasets. 
    The effectiveness of these models will be evaluated against baseline methods to ensure high accuracy and robustness 
    in real-world UAV environments.
    """)

# Research Objectives
with st.expander("🎯 **Research Objectives**"):
    st.markdown("""
    - Study and enhance spoofing/jamming detection using machine/deep learning  
    - Convert signals to spectrograms for better visual classification  
    - Build an interactive visualization interface  
    - Compare model performance with traditional approaches  
    - Improve model interpretability and real-time deployability
    """)

# Methodology & Tools
with st.expander("🛠️ **Methodology & Tools**"):
    st.markdown("""
    **Data Sources**  
    - Spoofing: 13-feature datasets from simulated UAV signals  
    - Jamming: Spectrogram image dataset from GNSS IQ data  

    **Tools**  
    - Python, PyCharm, Matplotlib, HTML  
    - ML Models: ResNet-34, CRNN, ViT  
    - STFT for signal transformation  
    """)

# Deliverables
with st.expander("📦 **Deliverables**"):
    st.markdown("""
    1. Detection model for spoofing/jamming  
    2. Enhanced dataset with location information  
    3. Research paper  
    4. Web interface/app or demo  
    """)


# Footer
st.markdown("---")
st.markdown("© 2025 IntercepTrak Team | For COMP7705 Project")

