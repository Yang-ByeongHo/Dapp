<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['image']) && $_FILES['image']['error'] == 0 && isset($_POST['artId']) && isset($_POST['pieceName']) && isset($_POST['price'])) {
        $artId = htmlspecialchars($_POST['artId']);
        $pieceName = htmlspecialchars($_POST['pieceName']); // 작품 이름 가져오기
        $price = htmlspecialchars($_POST['price']); // 가격 가져오기
        $uploadDir = 'uploads/'; // 이미지 파일을 저장할 디렉터리
        // $extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION); // 확장자 가져오기


        $uploadFile = $uploadDir . $artId . '_' . $pieceName . '_' . $price . '.' . "png"; // 파일명 설정

        // 디렉터리가 없는 경우 생성
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        // 이미지 파일을 지정된 디렉터리에 저장
        if (move_uploaded_file($_FILES['image']['tmp_name'], $uploadFile)) {
            echo "이미지가 성공적으로 업로드되었습니다: " . $uploadFile;
        } else {
            echo "이미지 업로드 실패.";
        }
    } else {
        echo "필드가 누락되었거나 파일이 업로드되지 않았습니다.";
    }
} else {
    echo "잘못된 요청 방식입니다.";
}
?>