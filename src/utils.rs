// pub fn add_prefix_to_hex(hex: &str) -> String {
//     if hex.is_empty() {
//         return "".to_string();
//     } else {
//         format! {"0x{}", hex}.to_string()
//     }
// }

// Timestamp to date conversion
// ex: 2015-07-30T16:02:18Z => 2015-07-30
pub fn block_time_to_date(block_time: &str) -> String {
    match block_time.split('T').next() {
        Some(date) => date.to_string(),
        None => "".to_string(),
    }
}