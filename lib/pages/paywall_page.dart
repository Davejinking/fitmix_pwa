import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/iron_theme.dart';
import '../core/service_locator.dart';
import '../services/subscription_service.dart';

/// Iron Log PRO Paywall 페이지
/// 고급스러운 프리미엄 업그레이드 유도 화면
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> 
    with SingleTickerProviderStateMixin {
  int _selectedPlan = 1; // 0: 월구독, 1: 평생소장 (기본 선택)
  bool _isLoading = false;
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IronTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 닫기 버튼
            _buildHeader(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // PRO 로고 & 타이틀
                    _buildProLogo(),
                    const SizedBox(height: 32),
                    
                    // 혜택 리스트
                    _buildBenefitsList(),
                    const SizedBox(height: 40),
                    
                    // 가격 옵션
                    _buildPricingOptions(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // 하단 구매 버튼
            _buildPurchaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 복원 버튼
          TextButton(
            onPressed: _handleRestore,
            child: Text(
              '구매 복원',
              style: TextStyle(
                color: IronTheme.textMedium,
                fontSize: 14,
              ),
            ),
          ),
          // 닫기 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: IronTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProLogo() {
    return Column(
      children: [
        // PRO 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade700,
                Colors.amber.shade500,
                Colors.amber.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.black,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // 타이틀
        const Text(
          'Iron Log PRO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '당신의 운동을 한 단계 업그레이드하세요',
          style: TextStyle(
            color: IronTheme.textMedium,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      ('무제한 루틴 생성', 'Free는 3개 제한'),
      ('모든 광고 제거', '깔끔한 운동 경험'),
      ('무제한 차트 분석', '상세한 성장 기록'),
      ('데이터 평생 소장', 'Local DB 영구 저장'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // 체크 아이콘
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade600,
                        Colors.amber.shade400,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                // 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        benefit.$2,
                        style: TextStyle(
                          color: IronTheme.textLow,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildPricingOptions() {
    return Column(
      children: [
        // 평생 소장 (강조) - Best Value
        _buildPlanCard(
          index: 1,
          title: '평생 소장',
          subtitle: 'Lifetime Access',
          price: '₩39,000',
          period: '일회성 결제',
          isPopular: true,
        ),
        const SizedBox(height: 12),
        
        // 월 구독
        _buildPlanCard(
          index: 0,
          title: '월 구독',
          subtitle: 'Monthly',
          price: '₩3,900',
          period: '/월',
          isPopular: false,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required bool isPopular,
  }) {
    final isSelected = _selectedPlan == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? IronTheme.surface 
              : IronTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Colors.amber 
                : IronTheme.surfaceHighlight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // 라디오 버튼
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.amber : IronTheme.textLow,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // 플랜 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : IronTheme.textMedium,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: IronTheme.textLow,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 가격
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: isSelected ? Colors.amber : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        color: IronTheme.textLow,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Best Value 태그
            if (isPopular)
              Positioned(
                top: -12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade600,
                        Colors.amber.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Best Value',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final planName = _selectedPlan == 1 ? '평생 소장' : '월 구독';
    final price = _selectedPlan == 1 ? '₩39,000' : '₩3,900/월';
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: IronTheme.background,
        border: Border(
          top: BorderSide(
            color: IronTheme.surfaceHighlight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 구매 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.amber.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      '$planName 시작하기 · $price',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 안내 문구
          Text(
            _selectedPlan == 1 
                ? '한 번 결제로 평생 이용' 
                : '언제든지 해지 가능',
            style: TextStyle(
              color: IronTheme.textLow,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    HapticFeedback.mediumImpact();
    
    setState(() => _isLoading = true);
    
    final productId = _selectedPlan == 1 ? 'lifetime_pro' : 'monthly_pro';
    print('🛒 구매 프로세스 시작: $productId');
    
    try {
      final success = await getIt<SubscriptionService>().purchase(productId);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Iron Log PRO가 되신 것을 환영합니다! 🎉'),
            backgroundColor: IronTheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구매 중 오류가 발생했습니다: $e'),
          backgroundColor: IronTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    HapticFeedback.lightImpact();
    print('🔄 구매 복원 시작');
    
    setState(() => _isLoading = true);

    try {
      final isPro = await getIt<SubscriptionService>().restorePurchases();

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (isPro) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '구매가 성공적으로 복원되었습니다! 🎉',
              style: TextStyle(
                color: IronTheme.textHigh,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: IronTheme.surfaceHighlight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('복원할 수 있는 구매 내역이 없습니다.'),
            backgroundColor: IronTheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('복원 중 오류가 발생했습니다: $e'),
          backgroundColor: IronTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
