/// Audio formatting and quality detection utilities
class AudioHelpers {
  AudioHelpers._();

  /// Format Duration to mm:ss or hh:mm:ss
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format milliseconds to Duration string
  static String formatMs(int ms) {
    return formatDuration(Duration(milliseconds: ms));
  }

  /// Format bitrate for display (e.g., "320 kbps")
  static String formatBitrate(int? bitrate) {
    if (bitrate == null || bitrate == 0) return '';
    if (bitrate >= 1000000) {
      return '${(bitrate / 1000000).toStringAsFixed(1)} Mbps';
    }
    return '${(bitrate / 1000).toStringAsFixed(0)} kbps';
  }

  /// Format sample rate for display (e.g., "44.1 kHz")
  static String formatSampleRate(int? sampleRate) {
    if (sampleRate == null || sampleRate == 0) return '';
    return '${(sampleRate / 1000).toStringAsFixed(1)} kHz';
  }

  /// Get audio format from file extension
  static String getFormat(String? filePath) {
    if (filePath == null) return 'Audio';
    final ext = filePath.split('.').last.toUpperCase();
    switch (ext) {
      case 'FLAC':
        return 'FLAC';
      case 'WAV':
        return 'WAV';
      case 'ALAC':
      case 'M4A':
        return ext;
      case 'MP3':
        return 'MP3';
      case 'AAC':
        return 'AAC';
      case 'OGG':
        return 'OGG';
      case 'WMA':
        return 'WMA';
      case 'OPUS':
        return 'OPUS';
      case 'AIFF':
      case 'AIF':
        return 'AIFF';
      default:
        return ext;
    }
  }

  /// Get quality label based on format and bitrate
  static String getQualityLabel(String? filePath, int? bitrate) {
    final format = getFormat(filePath);
    // Lossless formats
    if (['FLAC', 'WAV', 'ALAC', 'AIFF'].contains(format)) {
      return 'Lossless';
    }
    // Lossy quality tiers
    if (bitrate != null) {
      if (bitrate >= 320000) return 'High';
      if (bitrate >= 192000) return 'Standard';
    }
    return 'Basic';
  }

  /// Get quality description string (e.g., "FLAC • 44.1 kHz • 1411 kbps")
  static String getQualityDescription(String? filePath, int? bitrate, int? sampleRate) {
    final parts = <String>[];
    final format = getFormat(filePath);
    parts.add(format);
    if (sampleRate != null && sampleRate > 0) {
      parts.add(formatSampleRate(sampleRate));
    }
    if (bitrate != null && bitrate > 0) {
      parts.add(formatBitrate(bitrate));
    }
    return parts.join(' • ');
  }

  /// Get file size formatted
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }
}
